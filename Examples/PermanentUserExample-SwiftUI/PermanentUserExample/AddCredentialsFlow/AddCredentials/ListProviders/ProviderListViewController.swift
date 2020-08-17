import TinkLink
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler?

    private let searchController = UISearchController(searchResultsController: nil)
    private var providers: [Provider]
    private var credentialsContext: CredentialsContext
    private var originalFinancialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode]
    private var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] {
        didSet {
            tableView.reloadData()
        }
    }

    init(providers: [Provider], credentialsContext: CredentialsContext, style: UITableView.Style) {
        self.providers = providers
        self.credentialsContext = credentialsContext
        self.financialInstitutionGroupNodes = ProviderTree(providers: providers).financialInstitutionGroups
        self.originalFinancialInstitutionGroupNodes = ProviderTree(providers: providers).financialInstitutionGroups
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension ProviderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        title = "Choose Bank"

        tableView.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroupNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let node = financialInstitutionGroupNodes[indexPath.row]
        if let imageTableViewCell = cell as? FixedImageSizeTableViewCell {
            if let url = node.imageURL {
                imageTableViewCell.setImage(url: url)
            }
            imageTableViewCell.setTitle(text: node.displayName)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
        switch financialInstitutionGroupNode {
        case .financialInstitutions(let financialInstitutionGroups):
            showFinancialInstitution(for: financialInstitutionGroups, title: financialInstitutionGroupNode.displayName)
        case .authenticationUserTypes(let authenticationUserTypeNodes):
            showAuthenticationUserTypePicker(for: authenticationUserTypeNodes, title: financialInstitutionGroupNode.displayName)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroupNode.displayName)
        case .credentialsKinds(let groups):
            showCredentialsKindPicker(for: groups)
        case .provider(let provider):
            showAddCredentials(for: provider)
        }
    }
}

// MARK: - Navigation

extension ProviderListViewController {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        let viewController = FinancialInstitutionPickerViewController(credentialsContext: credentialsContext)
        viewController.onCompletion = onCompletion
        viewController.title = title
        viewController.financialInstitutionNodes = financialInstitutionNodes
        show(viewController, sender: nil)
    }

    func showAuthenticationUserTypePicker(for authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode], title: String?) {
        let viewController = AuthenticationUserTypePickerViewController(credentialsContext: credentialsContext)
        viewController.authenticationUserTypeNodes = authenticationUserTypeNodes
        viewController.onCompletion = onCompletion
        viewController.title = title
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController(credentialsContext: credentialsContext)
        viewController.onCompletion = onCompletion
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        show(viewController, sender: nil)
    }

    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode]) {
        let viewController = CredentialsKindPickerViewController(credentialsContext: credentialsContext)
        viewController.onCompletion = onCompletion
        viewController.credentialsKindNodes = credentialsKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredentials(for provider: Provider) {
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsContext: credentialsContext)
        addCredentialsViewController.onCompletion = onCompletion
        show(addCredentialsViewController, sender: nil)
    }
}

// MARK: - UISearchResultsUpdating

extension ProviderListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            financialInstitutionGroupNodes = originalFinancialInstitutionGroupNodes.filter { $0.displayName.localizedCaseInsensitiveContains(text) }
        } else {
            financialInstitutionGroupNodes = originalFinancialInstitutionGroupNodes
        }
    }
}
