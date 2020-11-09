import TinkLink
import UIKit

/// A view controller that displays an interface for picking financial institution groups.
final class FinancialInstitutionGroupPickerViewController: UITableViewController {
    private let providerContext = Tink.shared.providerContext

    private let searchController = UISearchController(searchResultsController: nil)
    private var originalFinancialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = []
    private var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = [] {
        didSet {
            tableView.reloadData()
        }
    }
}

// MARK: - View Lifecycle

extension FinancialInstitutionGroupPickerViewController {
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

        providerContext.fetchProviders(filter: .default) { [weak self] result in
            do {
                let providers = try result.get()
                let tree = ProviderTree(providers: providers)
                DispatchQueue.main.async {
                    self?.financialInstitutionGroupNodes = tree.financialInstitutionGroups
                    self?.originalFinancialInstitutionGroupNodes = tree.financialInstitutionGroups
                }
            } catch {
                // TODO: Error handling
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension FinancialInstitutionGroupPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroupNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FixedImageSizeTableViewCell
        cell.accessoryType = .disclosureIndicator
        let group = financialInstitutionGroupNodes[indexPath.row]
        cell.title = group.displayName
        cell.imageURL = group.imageURL
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FinancialInstitutionGroupPickerViewController {
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

extension FinancialInstitutionGroupPickerViewController {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        let viewController = FinancialInstitutionPickerViewController()
        viewController.title = title
        viewController.financialInstitutionNodes = financialInstitutionNodes
        show(viewController, sender: nil)
    }

    func showAuthenticationUserTypePicker(for authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode], title: String?) {
        let viewController = AuthenticationUserTypePickerViewController()
        viewController.authenticationUserTypeNodes = authenticationUserTypeNodes
        viewController.title = title
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController()
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        show(viewController, sender: nil)
    }

    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode]) {
        let viewController = CredentialsKindPickerViewController()
        viewController.credentialsKindNodes = credentialsKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredentials(for provider: Provider) {
        let addCredentialViewController = AddCredentialsViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}

// MARK: - UISearchResultsUpdating

extension FinancialInstitutionGroupPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            financialInstitutionGroupNodes = originalFinancialInstitutionGroupNodes.filter { $0.displayName.localizedCaseInsensitiveContains(text) }
        } else {
            financialInstitutionGroupNodes = originalFinancialInstitutionGroupNodes
        }
    }
}
