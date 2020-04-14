import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialsKindPickerViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler?
    var credentialKindNodes: [ProviderTree.CredentialKindNode] = []
    
    private let credentialsController: CredentialsController

    init(credentialsController: CredentialsController) {
        self.credentialsController = credentialsController

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension CredentialsKindPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Credentials Type"
        navigationItem.title = credentialKindNodes.first?.provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension CredentialsKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = credentialKindNodes[indexPath.row].displayDescription
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialKindNode = credentialKindNodes[indexPath.row]
        showAddCredential(for: credentialKindNode.provider)
    }
}

// MARK: - Navigation

extension CredentialsKindPickerViewController {
    func showAddCredential(for provider: Provider) {
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsController: credentialsController)
        addCredentialsViewController.onCompletion = onCompletion
        show(addCredentialsViewController, sender: nil)
    }
}
