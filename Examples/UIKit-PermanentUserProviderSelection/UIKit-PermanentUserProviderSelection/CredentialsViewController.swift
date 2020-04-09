import TinkLink
import UIKit

class CredentialsViewController: UITableViewController {
    private let dateFormatter = DateFormatter()

    private let userContext = UserContext()
    private let credentialContext = CredentialsContext()
    private let providerContext = ProviderContext()

    private var user: User?

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

        let addBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCredential))
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), addBarItem]

        navigationItem.leftBarButtonItem = editButtonItem

        tableView.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "Cell")

        activityIndicator.startAnimating()

        userContext.authenticateUser(accessToken: AccessToken(rawValue: "YOUR_ACCESS_TOKEN")!) { [weak self] result in
            dump(result)
            do {
                self?.user = try result.get()
                self?.updateList()
            } catch {
                // Handle any errors
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if user != nil {
            updateList()
        }
    }

    private func updateList() {
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

        credentialContext.fetchCredentialsList { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                do {
                    self?.credentialsList = try result.get()
                } catch {
                    // Handle any errors
                }
            }
        }
    }
}

// MARK: - Actions

extension CredentialsViewController {
    @objc private func addCredential(sender: UIBarButtonItem) {
        let providerListViewController = ProviderListViewController()
        providerListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddingCredentials))
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        navigationController.presentationController?.delegate = self
        present(navigationController, animated: true)
    }

    @objc private func cancelAddingCredentials(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CredentialsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if user != nil {
            updateList()
        }
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
        let provider = providersByID[credentials.providerID]
        let refreshCredentialsViewController = RefreshCredentialsViewController(credentials: credentials)
        refreshCredentialsViewController.title = provider?.displayName ?? "Credentials"
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
        credentialContext.delete(credentials) { [weak self] (result) in
            do {
                _ = try result.get()
                self?.credentialsList.remove(at: indexPath.item)
            } catch {
                // Handle any errors
            }
        }
    }
}
