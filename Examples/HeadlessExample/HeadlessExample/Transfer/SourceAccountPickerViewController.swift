import UIKit
import TinkLink

protocol SourceAccountPickerViewControllerDelegate: AnyObject {
    func sourceAccountPickerViewController(_ viewController: SourceAccountPickerViewController, didSelectAccount account: Account)
}

/// A view controller that displays an interface for picking source accounts.
final class SourceAccountPickerViewController: UITableViewController {
    private let transferContext = Tink.shared.transferContext

    weak var delegate: SourceAccountPickerViewControllerDelegate?

    private var sourceAccounts: [Account] = []
    private let selectedAccount: Account?

    private var canceller: RetryCancellable?

    init(selectedAccount: Account? = nil) {
        self.selectedAccount = selectedAccount
        super.init(style: .plain)
        title = "Select Account"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        canceller?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")

        canceller = transferContext.fetchAccounts { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.sourceAccounts = try result.get()
                    self?.tableView.reloadData()
                } catch {
                    self?.showAlert(for: error)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceAccounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let account = sourceAccounts[indexPath.row]
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = account.accountNumber
        cell.accessoryType = account.id == selectedAccount?.id ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = sourceAccounts[indexPath.row]
        delegate?.sourceAccountPickerViewController(self, didSelectAccount: account)
    }
}
