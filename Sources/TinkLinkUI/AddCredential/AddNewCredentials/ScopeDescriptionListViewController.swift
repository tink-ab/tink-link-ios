import UIKit
import TinkLinkSDK

final class ScopeDescriptionListViewController: UITableViewController {

    private let authorizationContext: AuthorizationContext

    private let scope: TinkLink.Scope

    enum Section {
        case intro(title: String, description: String)
        case scopeDescriptions([ScopeDescription])
    }

    var sections: [Section] {
        didSet {
            tableView.reloadData()
        }
    }

    init(user: User, scope: TinkLink.Scope) {
        self.authorizationContext = AuthorizationContext(user: user)
        self.scope = scope
        self.sections = [
            .intro(
                title: "We’ll collect the following data from you",
                description: "By following through this service, we’ll collect financial data from you. These are the data points we will collect from you:"
            )
        ]
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

        authorizationContext.scopeDescriptions(scope: scope) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let scopeDescriptions = try result.get()
                    self?.sections.append(.scopeDescriptions(scopeDescriptions))
                } catch {
                    // TODO: Error handling.
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ScopeDescriptionListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .intro:
            return 1
        case .scopeDescriptions(let scopeDescriptions):
            return scopeDescriptions.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScopeDescriptionCell
        switch sections[indexPath.section] {
        case .intro(let title, let description):
            cell.titleLabel.text = title
            cell.descriptionLabel.text = description
        case .scopeDescriptions(let scopeDescriptions):
            let scopeDescription = scopeDescriptions[indexPath.row]
            cell.titleLabel.text = scopeDescription.title
            cell.descriptionLabel.text = scopeDescription.description
        }
        return cell
    }
}
