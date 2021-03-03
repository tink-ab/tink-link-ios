import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class FinancialServicesTypePickerViewController: UITableViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let financialServicesTypeNodes: [ProviderTree.FinancialServicesNode]

    let listFormatter = HumanEnumeratedFormatter()

    init(financialServicesTypeNodes: [ProviderTree.FinancialServicesNode]) {
        self.financialServicesTypeNodes = financialServicesTypeNodes
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension FinancialServicesTypePickerViewController {
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

extension FinancialServicesTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialServicesTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = financialServicesTypeNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(ofType: CredentialsKindCell.self, for: indexPath)

        if node.financialServices.count == 1, let financialService = node.financialServices.first {
            switch financialService.segment {
            case .business:
                cell.setIcon(.business)
                cell.setTitle(text: financialService.shortName ?? Strings.SelectAuthenticationUserType.business)
            case .personal:
                cell.setIcon(.profile)
                cell.setTitle(text: financialService.shortName ?? Strings.SelectAuthenticationUserType.personal)
            case .unknown:
                assertionFailure("Unknown authentication user type")
            @unknown default:
                assertionFailure("Unknown authentication user type")
            }
        } else {
            let shortNames = node.financialServices.compactMap(\.shortName)
            // TODO: What to do as the fallback?
            let formattedNames = listFormatter.string(for: shortNames)
            cell.setTitle(text: formattedNames)
        }

        let isBeta = node.providers.contains(where: { $0.releaseStatus == .beta })
        cell.setBetaLabelHidden(!isBeta)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let authenticationUserTypeNode = financialServicesTypeNodes[indexPath.row]
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
