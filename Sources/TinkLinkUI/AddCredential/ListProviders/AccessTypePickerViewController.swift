import TinkLink
import UIKit

/// Example of how to use the provider grouped by access type
final class AccessTypePickerViewController: UITableViewController {

    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    let accessTypeNodes: [ProviderTree.AccessTypeNode]

    init(accessTypeNodes: [ProviderTree.AccessTypeNode]) {
        self.accessTypeNodes = accessTypeNodes
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AccessTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.separatorStyle = .none
        tableView.register(AccessTypeCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = Color.groupedBackground
    }
}

// MARK: - UITableViewDataSource

extension AccessTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let node = accessTypeNodes[indexPath.row]
        if let accessTypeCell = cell as? AccessTypeCell {
            if let url = node.imageURL {
                accessTypeCell.setImage(url: url)
            }
            accessTypeCell.setTitle(text: node.accessType.description)
            accessTypeCell.setDetail(text: "Including everyday accounts, such as your salary account")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessTypeNode = accessTypeNodes[indexPath.row]
        switch accessTypeNode {
        case .credentialKinds(let groups):
            addCredentialNavigator?.showCredentialKindPicker(for: groups, title: nil)
        case .provider(let provider):
            addCredentialNavigator?.showAddCredential(for: provider)
        }
    }
}
