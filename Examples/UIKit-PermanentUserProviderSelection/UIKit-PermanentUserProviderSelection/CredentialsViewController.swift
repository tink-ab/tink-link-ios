import TinkLink
import UIKit

class CredentialsViewController: UITableViewController {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private let userController = UserController()
    private var credentialController = CredentialController()
    private var providerController = ProviderController()

    private var credentials: [Credentials]? {
        didSet {
            if credentials != nil {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
            tableView.reloadData()
        }
    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        tableView.backgroundView = activityIndicator

        title = "Credentials"

        let addBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCredential))
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), addBarItem]

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshCredentials))
        navigationItem.leftBarButtonItem = editButtonItem

        tableView.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "Cell")

        NotificationCenter.default.addObserver(self, selector: #selector(updateCredentials), name: .providerControllerDidUpdateProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCredentials), name: .credentialControllerDidUpdateCredentials, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCredentials), name: .credentialControllerDidAddCredential, object: nil)

        userController.authenticateUser(accessToken: AccessToken(rawValue: "YOUR_ACCESS_TOKEN")!) { [weak self] result in
            guard let self = self else { return }
            do {
                let user = try result.get()
                self.providerController.performFetch()
            } catch {
                // Handle any errors
            }
        }
    }

    @objc private func updateCredentials() {
        DispatchQueue.main.async {
            self.credentials = self.credentialController.credentials
        }
    }

    @objc private func refreshCredentials(sender: UIBarButtonItem) {
        let refreshCredentialViewController = RefreshCredentialViewController(
            titleText: "Update banks & services",
            credentialController: credentialController,
            providerController: providerController,
            dismissAction: { refreshCredentialViewController in
                refreshCredentialViewController.dismiss(animated: false)
        }) { [weak self] credentialsToRefresh in
            self?.credentialController.performRefresh(credentialsToRefresh)
        }
        view.tintAdjustmentMode = .dimmed
        refreshCredentialViewController.modalPresentationStyle = .overFullScreen
        present(refreshCredentialViewController, animated: false)
    }

    @objc func addCredential(sender: UIBarButtonItem) {
        let providerListViewController = ProviderListViewController(style: .plain, providerController: providerController, credentialController: credentialController)
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        present(navigationController, animated: true)
    }
}

extension CredentialsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentials?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let credential = credentials?[indexPath.row] else {
            fatalError()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FixedImageSizeTableViewCell
        let provider = providerController.provider(providerID: credential.providerID)
        cell.setTitle(text: provider?.displayName ?? credential.kind.description)
        cell.setSubtitle(text: dateFormatter.string(from: credential.updated ?? Date()))
        provider?.image.flatMap { cell.setImage(url: $0) }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let credentialToDelete = credentials?[indexPath.item] {
            credentialController.deleteCredential([credentialToDelete])
            credentials?.remove(at: indexPath.item)
        }
    }
}
