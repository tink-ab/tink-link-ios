import TinkLink
import UIKit

final class CredentialsKindPickerViewController: UITableViewController {
    var credentialsKindNodes: [ProviderTree.CredentialsKindNode] = []
}

// MARK: - View Lifecycle

extension CredentialsKindPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Credentials Type"
        navigationItem.title = credentialsKindNodes.first?.provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension CredentialsKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialsKindNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = credentialsKindNodes[indexPath.row].displayDescription
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CredentialsKindPickerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialsKindNode = credentialsKindNodes[indexPath.row]
        showAddCredential(for: credentialsKindNode.provider)
    }
}

// MARK: - Navigation

extension CredentialsKindPickerViewController {
    func showAddCredential(for provider: Provider) {
        let addCredentialsViewController = AddCredentialsViewController(provider: provider)
        show(addCredentialsViewController, sender: nil)
    }
}
