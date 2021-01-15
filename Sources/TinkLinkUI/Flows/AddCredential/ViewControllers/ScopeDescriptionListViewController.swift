import UIKit
import TinkLink

protocol ScopeDescriptionListViewControllerDelegate: AnyObject {
    func scopeDescriptionListViewController(viewController: ScopeDescriptionListViewController, error: Error)
}

final class ScopeDescriptionListViewController: UITableViewController {
    weak var delegate: ScopeDescriptionListViewControllerDelegate?
    private let authorizationController: AuthorizationController

    private let scopes: [Scope]

    private lazy var activityIndicatorView = ActivityIndicatorView()

    private enum Section {
        case intro(title: String, description: String)
        case scopeDescriptions([ScopeDescription])
    }

    private var sections: [Section] {
        didSet {
            tableView.reloadData()
        }
    }

    init(authorizationController: AuthorizationController, scopes: [Scope]) {
        self.authorizationController = authorizationController
        self.scopes = scopes
        self.sections = [
            .intro(
                title: Strings.ConsentInformation.title,
                description: Strings.ConsentInformation.description
            )
        ]
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension ScopeDescriptionListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Color.background

        tableView.backgroundView = activityIndicatorView

        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.registerReusableCell(ofType: ScopeDescriptionCell.self)

        activityIndicatorView.tintColor = Color.accent
        activityIndicatorView.startAnimating()

        authorizationController.scopeDescriptions(scopes: scopes) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()

                do {
                    let scopeDescriptions = try result.get()
                    self.sections.append(.scopeDescriptions(scopeDescriptions))
                } catch {
                    self.showAlert(for: error)
                }
            }
        }
    }

    private func showAlert(for error: Error) {
        let title: String
        let message: String?
        if let error = error as? LocalizedError {
            title = error.errorDescription ?? Strings.Generic.error
            message = error.failureReason
        } else {
            title = Strings.Generic.error
            message = error.localizedDescription
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: Strings.Generic.ok, style: .default) { _ in
            self.delegate?.scopeDescriptionListViewController(viewController: self, error: error)
        }
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(ofType: ScopeDescriptionCell.self, for: indexPath)
        switch sections[indexPath.section] {
        case .intro(let title, let description):
            cell.configure(title: title, titleFont: Font.header6, description: description)
        case .scopeDescriptions(let scopeDescriptions):
            let scopeDescription = scopeDescriptions[indexPath.row]
            cell.configure(title: scopeDescription.title, description: scopeDescription.description)
        }
        return cell
    }
}
