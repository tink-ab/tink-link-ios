import TinkLink
import UIKit

/// A view controller that displays an interface for picking financial institutions.
final class FinancialInstitutionPickerViewController: UITableViewController {
    var financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode] = []
}

// MARK: - View Lifecycle

extension FinancialInstitutionPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Financial Institution"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension FinancialInstitutionPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let node = financialInstitutionNodes[indexPath.row]
        if let imageTableViewCell = cell as? FixedImageSizeTableViewCell {
            imageTableViewCell.imageURL = node.imageURL
            imageTableViewCell.title = node.financialInstitution.name
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FinancialInstitutionPickerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionNode = financialInstitutionNodes[indexPath.row]
        switch financialInstitutionNode {
        case .authenticationUserTypes(let authenticationUserTypeNodes):
            showAuthenticationUserTypePicker(for: authenticationUserTypeNodes, title: financialInstitutionNode.financialInstitution.name)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionNode.financialInstitution.name)
        case .credentialsKinds(let groups):
            showCredentialsKindPicker(for: groups, title: financialInstitutionNode.financialInstitution.name)
        case .provider(let provider):
            showAddCredentials(for: provider)
        }
    }
}

// MARK: - Navigation

extension FinancialInstitutionPickerViewController {
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

    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode], title: String?) {
        let viewController = CredentialsKindPickerViewController()
        viewController.title = title
        viewController.credentialsKindNodes = credentialsKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredentials(for provider: Provider) {
        let addCredentialViewController = AddCredentialsViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}
