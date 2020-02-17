import TinkLinkSDK
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialKindPickerViewController: UITableViewController {
    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    let credentialKindNodes: [ProviderTree.CredentialKindNode]

    init(credentialKindNodes: [ProviderTree.CredentialKindNode]) {
        self.credentialKindNodes = credentialKindNodes
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension CredentialKindPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = credentialKindNodes.first?.provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(CredentialKindCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - UITableViewDataSource

extension CredentialKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let node = credentialKindNodes[indexPath.row]
        let icon: Icon = node.credentialKind == .mobileBankID ? .bankID : .password
        if let credentialKindCell = cell as? CredentialKindCell {
            credentialKindCell.setIcon(icon)
            credentialKindCell.setTitle(text: node.credentialKind.description)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialKindNode = credentialKindNodes[indexPath.row]
        addCredentialNavigator?.showAddCredential(for: credentialKindNode.provider)
    }
}
