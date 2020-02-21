import TinkLink
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    private var providerController: ProviderController?
    private var credentialController: CredentialController?
    private var user: User?

    private let searchController = UISearchController(searchResultsController: nil)
    private var originalFinancialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = []
    private var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    init(style: UITableView.Style, providerController: ProviderController, credentialController: CredentialController) {
        self.providerController = providerController
        self.credentialController = credentialController
        financialInstitutionGroupNodes = providerController.financialInstitutionGroupNodes

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

        NotificationCenter.default.addObserver(self, selector: #selector(updateProviders), name: .providerControllerDidUpdateProviders, object: nil)

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        title = "Choose Bank"

        tableView.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @objc private func updateProviders() {
        DispatchQueue.main.async {
            self.financialInstitutionGroupNodes = self.providerController?.financialInstitutionGroupNodes ?? []
        }
    }
}

// MARK: - UITableViewDataSource

extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroupNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        let group = financialInstitutionGroupNodes[indexPath.row]
        if let imageViewCell = cell as? FixedImageSizeTableViewCell {
            imageViewCell.setTitle(text: group.displayName)
            if let url = group.imageURL {
                imageViewCell.setImage(url: url)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
        switch financialInstitutionGroupNode {
        case .financialInstitutions(let financialInstitutionGroups):
            showFinancialInstitution(for: financialInstitutionGroups, title: financialInstitutionGroupNode.displayName)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroupNode.displayName)
        case .credentialKinds(let groups):
            showCredentialKindPicker(for: groups)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension ProviderListViewController {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        guard let credentialController = credentialController else { return }
        let viewController = FinancialInstitutionPickerViewController(credentialController: credentialController)
        viewController.title = title
        viewController.financialInstitutionNodes = financialInstitutionNodes
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        guard let credentialController = credentialController else { return }
        let viewController = AccessTypePickerViewController(credentialController: credentialController)
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode]) {
        guard let credentialController = credentialController else { return }
        let viewController = CredentialKindPickerViewController(credentialController: credentialController)
        viewController.credentialKindNodes = credentialKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        guard let credentialController = credentialController else { return }
        let addCredentialViewController = AddCredentialViewController(provider: provider, credentialController: credentialController)
        show(addCredentialViewController, sender: nil)
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
