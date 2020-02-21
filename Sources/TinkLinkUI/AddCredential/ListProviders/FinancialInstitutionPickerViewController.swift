import TinkLinkSDK
import UIKit

/// Example of how to use the provider grouped by financialInstitution
final class FinancialInstitutionPickerViewController: UITableViewController {

    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    let financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode]

    init(financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode]) {
        self.financialInstitutionNodes = financialInstitutionNodes
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension FinancialInstitutionPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.registerReusableCell(ofType: ProviderCell.self)
        tableView.tableFooterView = UIView(frame: .zero)
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
        case .accessTypes(let accessTypeGroups):
            addCredentialNavigator?.showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionNode.financialInstitution.name)
        case .credentialKinds(let groups):
            addCredentialNavigator?.showCredentialKindPicker(for: groups, title: financialInstitutionNode.financialInstitution.name)
        case .provider(let provider):
            addCredentialNavigator?.showAddCredential(for: provider)
        }
    }
}
