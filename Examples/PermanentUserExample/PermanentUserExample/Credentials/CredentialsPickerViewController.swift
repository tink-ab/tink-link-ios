import TinkLink
import UIKit

class CredentialsPickerViewController: UITableViewController {
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

extension CredentialsPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true

        tableView.backgroundView = activityIndicator

        title = "Credentials"

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

extension CredentialsPickerViewController {
    private func updateList(completion: (() -> Void)? = nil) {
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        providerContext.fetchProviders(attributes: attributes) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let providers = try result.get()
                    self?.providersByID = Dictionary(grouping: providers, by: { $0.id }).compactMapValues { $0.first }
                } catch {
                    self?.showAlert(for: error)
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

extension CredentialsPickerViewController {
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        updateList {
            refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension CredentialsPickerViewController {
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
}

// MARK: - UITableViewDelegate

extension CredentialsPickerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentials = credentialsList[indexPath.row]
        guard let provider = providersByID[credentials.providerID] else {
            fatalError("Cannot find corresponding provider")
        }

        let refreshCredentialsViewController = CredentialsDetailViewController(credentials: credentials, provider: provider)
        refreshCredentialsViewController.title = provider.displayName
        show(refreshCredentialsViewController, sender: self)
    }
}
