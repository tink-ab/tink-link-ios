import TinkLink
import UIKit

/// Example of how to use the provider grouped by access type
final class AccessTypePickerViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler?
    var accessTypeNodes: [ProviderTree.AccessTypeNode] = []

    private let credentialsContext: CredentialsContext

    init(credentialsContext: CredentialsContext) {
        self.credentialsContext = credentialsContext

        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AccessTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Access Type"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension AccessTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch accessTypeNodes[indexPath.row].accessType {
        case .openBanking:
            cell.textLabel?.text = "Open Banking"
        case .other:
            cell.textLabel?.text = "Other"
        case .unknown:
            cell.textLabel?.text = "Unknown"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessTypeNode = accessTypeNodes[indexPath.row]
        switch accessTypeNode {
        case .credentialsKinds(let groups):
            showCredentialsKindPicker(for: groups)
        case .provider(let provider):
            showAddCredentials(for: provider)
        }
    }
}

// MARK: - Navigation

extension AccessTypePickerViewController {
    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode]) {
        let viewController = CredentialsKindPickerViewController(credentialsContext: credentialsContext)
        viewController.onCompletion = onCompletion
        viewController.credentialsKindNodes = credentialsKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredentials(for provider: Provider) {
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsContext: credentialsContext)
        addCredentialsViewController.onCompletion = onCompletion
        show(addCredentialsViewController, sender: nil)
    }
}
