import UIKit
import TinkLinkSDK

final class ScopeDescriptionListViewController: UITableViewController {

    private let authorizationContext: AuthorizationContext

    private var scopeDescriptions: [ScopeDescription] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    init(user: User) {
        self.authorizationContext = AuthorizationContext(user: user)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle
extension ScopeDescriptionListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Color.background

        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.register(ScopeDescriptionCell.self, forCellReuseIdentifier: "Cell")

        let scope = TinkLink.Scope(scopes: [
            TinkLink.Scope.Statistics.read,
            TinkLink.Scope.Transactions.read,
            TinkLink.Scope.Categories.read,
            TinkLink.Scope.Accounts.read
        ])
        authorizationContext.scopeDescriptions(scope: scope) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.scopeDescriptions = try result.get()
                } catch {
                    // TODO: Error handling.
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ScopeDescriptionListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scopeDescriptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScopeDescriptionCell
        let scopeDescription = scopeDescriptions[indexPath.row]
        cell.titleLabel.text = scopeDescription.title
        cell.descriptionLabel.text = scopeDescription.description
        return cell
    }
}
