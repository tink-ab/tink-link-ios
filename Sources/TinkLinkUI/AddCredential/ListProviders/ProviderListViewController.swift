import TinkLinkSDK
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {

    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    private var providerController: ProviderController?

    private let searchViewController = FinancialInstitutionSearchViewController()
    
    private lazy var searchController = UISearchController(searchResultsController: searchViewController)
    
    private var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    init(providerController: ProviderController) {
        self.providerController = providerController
        financialInstitutionGroupNodes = providerController.financialInstitutionGroupNodes
        searchViewController.originalFinancialInstitutionNodes = providerController.financialInstitutionNodes
        
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension ProviderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingIndicator), name: .providerControllerWillFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingIndicator), name: .providerControllerDidFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProviders), name: .providerControllerDidUpdateProviders, object: nil)
        
        extendedLayoutIncludesOpaqueBars = true
        
        searchViewController.addCredentialNavigator = addCredentialNavigator
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search for a bank or card"
        searchController.searchResultsUpdater = searchViewController
 
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        title = "Choose Bank"

        tableView.registerReusableCell(ofType: ProviderCell.self)

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator

        if providerController?.isFetching == true {
            showLoadingIndicator()
        }

    }

    @objc private func showLoadingIndicator() {
        DispatchQueue.main.async {
            let activityIndicatorView = UIActivityIndicatorView()
            activityIndicatorView.startAnimating()
            self.tableView.backgroundView = activityIndicatorView
        }
    }

    @objc private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.tableView.backgroundView = nil
        }
    }

    @objc private func updateProviders() {
        DispatchQueue.main.async {
            self.financialInstitutionGroupNodes = self.providerController?.financialInstitutionGroupNodes ?? []
            self.searchViewController.originalFinancialInstitutionNodes = self.providerController?.financialInstitutionNodes ?? []
        }
    }
}

// MARK: - UITableViewDataSource

extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroupNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = financialInstitutionGroupNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(ofType: ProviderCell.self, for: indexPath)
        cell.setTitle(text: group.displayName)
        if let url = group.imageURL {
            cell.setImage(url: url)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
        switch financialInstitutionGroupNode {
        case .financialInstitutions(let financialInstitutionGroups):
            addCredentialNavigator?.showFinancialInstitution(for: financialInstitutionGroups, title: financialInstitutionGroupNode.displayName)
        case .accessTypes(let accessTypeGroups):
            addCredentialNavigator?.showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroupNode.displayName)
        case .credentialKinds(let groups):
            addCredentialNavigator?.showCredentialKindPicker(for: groups, title: nil)
        case .provider(let provider):
            addCredentialNavigator?.showAddCredential(for: provider)
        }
    }
}
