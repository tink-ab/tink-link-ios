import TinkLink
import UIKit

class CredentialsViewController: UITableViewController {
    private let dateFormatter = DateFormatter()

    private let credentialsContext = CredentialsContext()
    private let providerContext = ProviderContext()

    private var providersByID: [Provider.ID: Provider] = [:] {
        didSet {
            tableView.reloadData()
        }
    }
    private var credentialsList: [Credentials] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
}

// MARK: - View Lifecycle

extension CredentialsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true

        tableView.backgroundView = activityIndicator

        title = "Credentials"

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCredentials))

        toolbarItems = [
            UIBarButtonItem(title: "Transfer", style: .plain, target: self, action: #selector(transfer))
        ]

        tableView.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        activityIndicator.startAnimating()

        updateList { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateList()
    }
}

// MARK: - Data

extension CredentialsViewController {
    private func updateList(completion: (() -> Void)? = nil) {
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        providerContext.fetchProviders(attributes: attributes) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let providers = try result.get()
                    self?.providersByID = Dictionary(grouping: providers, by: { $0.id }).compactMapValues({ $0.first })
                } catch {
                    // Handle any errors
                }
            }
        }

        credentialsContext.fetchCredentialsList { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.credentialsList = try result.get()
                } catch {
                    // Handle any errors
                }
                completion?()
            }
        }
    }
}

// MARK: - Actions

extension CredentialsViewController {
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        updateList {
            refreshControl.endRefreshing()
        }
    }

    @objc private func addCredentials(sender: UIBarButtonItem) {
        let providerListViewController = ProviderListViewController()
        providerListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddingCredentials))
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    @objc private func cancelAddingCredentials(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc private func transfer(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: - UITableViewDataSource

extension CredentialsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let credentials = credentialsList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FixedImageSizeTableViewCell
        let provider = providersByID[credentials.providerID]
        cell.title = provider?.displayName
        cell.subtitle = credentials.updated.map(dateFormatter.string(from:))
        cell.imageURL = provider?.image
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentials = credentialsList[indexPath.row]
        guard let provider = providersByID[credentials.providerID] else {
            fatalError("Cannot find corresponding provider")
        }

        let refreshCredentialsViewController = RefreshCredentialsViewController(credentials: credentials, provider: provider)
        refreshCredentialsViewController.title = provider.displayName
        show(refreshCredentialsViewController, sender: self)
    }
}

// MARK: - UITableViewDelegate

extension CredentialsViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let credentials = credentialsList[indexPath.row]
        credentialsContext.delete(credentials) { [weak self] (result) in
            DispatchQueue.main.async {
                do {
                    _ = try result.get()
                    self?.credentialsList.remove(at: indexPath.item)
                } catch {
                    // Handle any errors
                }
            }
        }
    }
}
