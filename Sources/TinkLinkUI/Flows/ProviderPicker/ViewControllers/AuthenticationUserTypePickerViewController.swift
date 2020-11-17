import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class AuthenticationUserTypePickerViewController: UITableViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode]

    init(authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode]) {
        self.authenticationUserTypeNodes = authenticationUserTypeNodes.filter { $0.authenticationUserType != .unknown }
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AuthenticationUserTypePickerViewController {
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

extension AuthenticationUserTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authenticationUserTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = authenticationUserTypeNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(ofType: CredentialsKindCell.self, for: indexPath)

        switch node.authenticationUserType {
        case .business:
            cell.setIcon(.business)
            cell.setTitle(text: Strings.SelectAuthenticationUserType.business)
        case .personal:
            cell.setIcon(.profile)
            cell.setTitle(text: Strings.SelectAuthenticationUserType.personal)
        case .corporate:
            cell.setIcon(.corporate)
            cell.setTitle(text: Strings.SelectAuthenticationUserType.corporate)
        case .unknown:
            assertionFailure("Unknown authentication user type")
        @unknown default:
            assertionFailure("Unknown authentication user type")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let authenticationUserTypeNode = authenticationUserTypeNodes[indexPath.row]
        switch authenticationUserTypeNode {
        case .accessTypes(let accessTypeGroups):
            providerPickerCoordinator?.showAccessTypePicker(for: accessTypeGroups, name: authenticationUserTypeNode.financialInstitution.name)
        case .credentialsKinds(let groups):
            providerPickerCoordinator?.showCredentialsKindPicker(for: groups)
        case .provider(let provider):
            providerPickerCoordinator?.didSelectProvider(provider)
        }
    }
}
