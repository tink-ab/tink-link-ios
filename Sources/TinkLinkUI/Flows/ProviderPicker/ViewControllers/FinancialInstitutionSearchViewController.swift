import UIKit
import TinkLink

final class FinancialInstitutionSearchViewController: UITableViewController {

    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    var originalFinancialInstitutionNodes: [ProviderTree.FinancialInstitutionNode] = []
    
    private var financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    init() {
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension FinancialInstitutionSearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background
        tableView.registerReusableCell(ofType: ProviderCell.self)
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - UITableViewDataSource

extension FinancialInstitutionSearchViewController {
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
        case .accessTypes(let accessTypeGroups):
            providerPickerCoordinator?.showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionNode.financialInstitution.name)
        case .credentialKinds(let groups):
            providerPickerCoordinator?.showCredentialKindPicker(for: groups)
        case .provider(let provider):
            providerPickerCoordinator?.didSelectProvider(provider)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension FinancialInstitutionSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            financialInstitutionNodes = originalFinancialInstitutionNodes.filter { $0.financialInstitution.name.localizedCaseInsensitiveContains(text) }
        } else {
            financialInstitutionNodes = originalFinancialInstitutionNodes
        }
    }
}

