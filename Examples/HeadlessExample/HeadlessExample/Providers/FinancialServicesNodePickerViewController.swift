import TinkLink
import UIKit

/// A view controller that displays an interface for picking authentication user types.
final class FinancialServicesNodePickerViewController: UITableViewController {
    var financialServicesNodes: [ProviderTree.FinancialServicesNode] = []
}

// MARK: - View Lifecycle

extension FinancialServicesNodePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - UITableViewDataSource

extension FinancialServicesNodePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialServicesNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = financialServicesNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator

        switch node.financialServices.first?.segment {
        case .business:
            cell.textLabel?.text = "Business"
        case .personal:
            cell.textLabel?.text = "Personal"
        default:
            fatalError("Unknown authentication user type")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialServicesNode = financialServicesNodes[indexPath.row]
        switch financialServicesNode {
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialServicesNode.financialInstitution.name)
        case .credentialsKinds(let groups):
            showCredentialsKindPicker(for: groups, title: financialServicesNode.financialInstitution.name)
        case .provider(let provider):
            showAddCredentials(for: provider)
        }
    }
}

// MARK: - Navigation

extension FinancialServicesNodePickerViewController {
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
