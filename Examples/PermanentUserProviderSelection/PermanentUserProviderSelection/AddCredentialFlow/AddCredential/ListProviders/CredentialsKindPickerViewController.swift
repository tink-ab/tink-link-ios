import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialsKindPickerViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler?
    var credentialsKindNodes: [ProviderTree.CredentialsKindNode] = []
    
    private let credentialsContext: CredentialsContext

    init(credentialsContext: CredentialsContext) {
        self.credentialsContext = credentialsContext

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
        navigationItem.title = credentialsKindNodes.first?.provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension CredentialsKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialsKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = credentialsKindNodes[indexPath.row].displayDescription
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialsKindsNode = credentialsKindNodes[indexPath.row]
        showAddCredential(for: credentialsKindNode.provider)
    }
}

// MARK: - Navigation

extension CredentialsKindPickerViewController {
    func showAddCredential(for provider: Provider) {
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsContext: credentialsContext)
        addCredentialsViewController.onCompletion = onCompletion
        show(addCredentialsViewController, sender: nil)
    }
}
