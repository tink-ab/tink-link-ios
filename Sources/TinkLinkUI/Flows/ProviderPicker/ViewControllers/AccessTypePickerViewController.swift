import TinkLink
import UIKit

/// Example of how to use the provider grouped by access type
final class AccessTypePickerViewController: UITableViewController {

    weak var providerPickerCoordinator: ProviderPickerCoordinating?

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
        tableView.registerReusableCell(ofType: AccessTypeCell.self)
        tableView.backgroundColor = Color.groupedBackground
        tableView.allowsSelection = false
    }
}

// MARK: - UITableViewDataSource

extension AccessTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = accessTypeNodes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(ofType: AccessTypeCell.self, for: indexPath)
        if let url = node.imageURL {
            cell.setImage(url: url)
        }
        switch node.accessType {
        case .openBanking:
            cell.setTitle(text: Strings.ProviderPicker.AccessType.openBankingTitle)
            cell.setDetail(text: Strings.ProviderPicker.AccessType.openBankingDetail)
        case .other, .unknown:
            cell.setTitle(text: Strings.ProviderPicker.AccessType.otherTitle)
            cell.setDetail(text: Strings.ProviderPicker.AccessType.otherDetail)
        }
        cell.delegate = self
        return cell
    }
}

extension AccessTypePickerViewController: AccessTypeCellDelegate {
    func accessTypeCellAddButtonTapped(_ accessTypeCell: AccessTypeCell) {

        guard let indexPath = tableView.indexPath(for: accessTypeCell) else {
            return
        }

        let accessTypeNode = accessTypeNodes[indexPath.row]

        switch accessTypeNode {
        case .credentialsKinds(let groups):
            providerPickerCoordinator?.showCredentialsKindPicker(for: groups)
        case .provider(let provider):
            providerPickerCoordinator?.didSelectProvider(provider)
        }
    }
}
