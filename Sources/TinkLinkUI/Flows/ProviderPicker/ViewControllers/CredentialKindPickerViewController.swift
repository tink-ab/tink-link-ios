import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialKindPickerViewController: UITableViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let credentialKindNodes: [ProviderTree.CredentialKindNode]

    init(credentialKindNodes: [ProviderTree.CredentialKindNode]) {
        self.credentialKindNodes = credentialKindNodes.sorted(by: { $0.credentialKind.description < $1.credentialKind.description })
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

        tableView.registerReusableCell(ofType: CredentialKindCell.self)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
    }
}

// MARK: - UITableViewDataSource

extension CredentialKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = credentialKindNodes[indexPath.row]
        let icon: Icon = node.credentialKind == .mobileBankID ? .bankID : .password

        let cell = tableView.dequeueReusableCell(ofType: CredentialKindCell.self, for: indexPath)
        cell.setIcon(icon)
        cell.setTitle(text: node.credentialKind.description)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialKindNode = credentialKindNodes[indexPath.row]
        providerPickerCoordinator?.didSelectProvider(credentialKindNode.provider)
    }
}
