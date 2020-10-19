import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialsKindPickerViewController: UITableViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let credentialsKindNodes: [ProviderTree.CredentialsKindNode]

    init(credentialsKindNodes: [ProviderTree.CredentialsKindNode]) {
        self.credentialsKindNodes = credentialsKindNodes
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension CredentialsKindPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.registerReusableCell(ofType: CredentialsKindCell.self)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
    }
}

// MARK: - UITableViewDataSource

extension CredentialsKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialsKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = credentialsKindNodes[indexPath.row]
        let icon: Icon = node.credentialsKind == .mobileBankID ? .bankID : .password

        let cell = tableView.dequeueReusableCell(ofType: CredentialsKindCell.self, for: indexPath)
        cell.setIcon(icon)
        cell.setTitle(text: node.displayDescription)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialsKindNode = credentialsKindNodes[indexPath.row]
        providerPickerCoordinator?.didSelectProvider(credentialsKindNode.provider)
    }
}
