import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class AuthenticationUserTypePickerViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    private let credentialsContext: CredentialsContext

    var authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode] = []
    var onCompletion: CompletionHandler?

    init(credentialsContext: CredentialsContext) {
        self.credentialsContext = credentialsContext

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AuthenticationUserTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - UITableViewDataSource

extension AuthenticationUserTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authenticationUserTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = authenticationUserTypeNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator

        switch node.authenticationUserType {
        case .business:
            cell.textLabel?.text = "Business"
        case .personal:
            cell.textLabel?.text = "Personal"
        case .unknown:
            fatalError("Unknow authentication user type")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let authenticationUserTypeNode = authenticationUserTypeNodes[indexPath.row]
        switch authenticationUserTypeNode {
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: authenticationUserTypeNode.financialInstitution.name)
        case .credentialsKinds(let groups):
            showCredentialsKindPicker(for: groups, title: authenticationUserTypeNode.financialInstitution.name)
        case .provider(let provider):
            showAddCredentials(for: provider)
        }
    }
}

// MARK: - Navigation

extension AuthenticationUserTypePickerViewController {
    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController(credentialsContext: credentialsContext)
        viewController.onCompletion = onCompletion
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        show(viewController, sender: nil)
    }

    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode], title: String?) {
        let viewController = CredentialsKindPickerViewController(credentialsContext: credentialsContext)
        viewController.onCompletion = onCompletion
        viewController.title = title
        viewController.credentialsKindNodes = credentialsKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredentials(for provider: Provider) {
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsContext: credentialsContext)
        addCredentialsViewController.onCompletion = onCompletion
        show(addCredentialsViewController, sender: nil)
    }
}
