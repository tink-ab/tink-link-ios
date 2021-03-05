import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class FinancialServicesTypePickerViewController: UITableViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?
    private let tinkLinkTracker: TinkLinkTracker

    let financialServicesTypeNodes: [ProviderTree.FinancialServicesNode]

    let listFormatter = HumanEnumeratedFormatter()

    init(financialServicesTypeNodes: [ProviderTree.FinancialServicesNode], tinkLinkTracker: TinkLinkTracker) {
        self.financialServicesTypeNodes = financialServicesTypeNodes
        self.tinkLinkTracker = tinkLinkTracker
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            tinkLinkTracker.track(interaction: .back, screen: .authenticationUserTypeSelection)
        }
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
                cell.setTitle(text: financialService.shortName.isEmpty ? Strings.SelectAuthenticationUserType.business : financialService.shortName)
            case .personal:
                cell.setIcon(.profile)
                cell.setTitle(text: financialService.shortName.isEmpty ? Strings.SelectAuthenticationUserType.personal : financialService.shortName)
            case .unknown:
                assertionFailure("Unknown financial services type")
            @unknown default:
                assertionFailure("Unknown financial services type")
            }
        } else {
            let shortNames = node.financialServices.map(\.shortName)
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
