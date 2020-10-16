import TinkLink
import UIKit

/// Example of how to use the provider grouped by financialInstitution
final class FinancialInstitutionPickerViewController: UITableViewController {
    private let searchViewController = FinancialInstitutionSearchViewController()
    private lazy var searchController = TinkSearchController(searchResultsController: searchViewController)

    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode]

    init(financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode]) {
        self.financialInstitutionNodes = financialInstitutionNodes
        searchViewController.originalFinancialInstitutionNodes = financialInstitutionNodes
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension FinancialInstitutionPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        if financialInstitutionNodes.count > 5 {
            searchViewController.providerPickerCoordinator = providerPickerCoordinator
            searchController.obscuresBackgroundDuringPresentation = true
            searchController.searchBar.placeholder = Strings.ProviderList.searchHint
            searchController.searchResultsUpdater = searchViewController

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }

        tableView.registerReusableCell(ofType: ProviderCell.self)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
    }
}

// MARK: - UITableViewDataSource

extension FinancialInstitutionPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = financialInstitutionNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(ofType: ProviderCell.self, for: indexPath)
        cell.setTitle(text: node.financialInstitution.name)
        if let url = node.imageURL {
            cell.setImage(url: url)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionNode = financialInstitutionNodes[indexPath.row]
        switch financialInstitutionNode {
        case .authenticationUserTypes(let authenticationUserTypeGroups):
            providerPickerCoordinator?.showAuthenticationUserTypePicker(for: authenticationUserTypeGroups)
        case .accessTypes(let accessTypeGroups):
            providerPickerCoordinator?.showAccessTypePicker(for: accessTypeGroups, name: financialInstitutionNode.financialInstitution.name)
        case .credentialsKinds(let groups):
            providerPickerCoordinator?.showCredentialsKindPicker(for: groups)
        case .provider(let provider):
            providerPickerCoordinator?.didSelectProvider(provider)
        }
    }
}
