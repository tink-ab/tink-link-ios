import TinkLinkSDK
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialKindPickerViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credential, Error>) -> Void
    var onCompletion: CompletionHandler?
    var credentialKindNodes: [ProviderTree.CredentialKindNode] = []

    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    init() {
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension CredentialKindPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = credentialKindNodes.first?.provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(ProviderCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - UITableViewDataSource

extension CredentialKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let node = credentialKindNodes[indexPath.row]
        if let providerCell = cell as? ProviderCell {
            if let url = node.imageURL {
                providerCell.setImage(url: url)
            }
            providerCell.setTitle(text: node.credentialKind.description)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialKindNode = credentialKindNodes[indexPath.row]
        addCredentialNavigator?.showAddCredential(for: credentialKindNode.provider)
    }
}
