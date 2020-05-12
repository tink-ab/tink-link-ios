import UIKit
import TinkLink

protocol SourceAccountPickerViewControllerDelegate: AnyObject {
    func sourceAccountPickerViewController(_ viewController: SourceAccountPickerViewController, didSelectAccount account: Account)
}

class SourceAccountPickerViewController: UITableViewController {
    private let transferContext = TransferContext()

    weak var delegate: SourceAccountPickerViewControllerDelegate?

    private var sourceAccounts: [Account] = []
    private let selectedAccount: Account?

    init(selectedAccount: Account? = nil) {
        self.selectedAccount = selectedAccount
        super.init(style: .plain)
        title = "Accounts"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        transferContext.sourceAccounts { [weak self] (result) in
            DispatchQueue.main.async {
                do {
                    self?.sourceAccounts = try result.get()
                    self?.tableView.reloadData()
                } catch {
                    // Handle any error
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
        cell.accessoryType = account.id == selectedAccount?.id ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = sourceAccounts[indexPath.row]
        delegate?.sourceAccountPickerViewController(self, didSelectAccount: account)
    }
}
