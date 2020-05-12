import UIKit
import TinkLink

class TransferViewController: UITableViewController {
    private let transferContext = TransferContext()

    private var sourceAccount: Account?
    private var transferDestination: TransferDestination?

    private enum Section {
        enum AccountField {
            case from
            case to
        }
        enum DetailField {
            case amount
            case message
        }
        case accounts([AccountField])
        case details([DetailField])
        case action
    }

    private let sections: [Section] = [.accounts([.from, .to]), .details([.amount, .message]), .action]

    init() {
        super.init(style: .insetGrouped)

        title = "Transfer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(Value2TableViewCell.self, forCellReuseIdentifier: "Value2")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextField")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "Button")
    }

    @objc private func transfer(_ sender: Any) {
        guard let sourceAccount = sourceAccount, let balance = sourceAccount.currencyDenominatedBalance else { return }
        
        _ = transferContext.initiateTransfer(
            amount: ExactNumber(value: 1),
            currencyCode: balance.currencyCode,
            credentialsID: sourceAccount.credentialsID,
            sourceURI: Transfer.TransferEntityURI("SOURCE_URI"),
            destinationURI: Transfer.TransferEntityURI("DESTINATION_URI"),
            message: "MESSAGE",
            completion: { result in
                dump(result)
            }
        )
    }

    @objc private func cancel(_ sender: Any) {
        dismiss(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .accounts:
            return 2
        case .details(let items):
            return items.count
        case .action:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .accounts(let fields):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Value2", for: indexPath)
            switch fields[indexPath.row] {
            case .from:
                cell.textLabel?.text = "From:"
                cell.detailTextLabel?.text = sourceAccount?.name
            case .to:
                cell.textLabel?.text = "To:"
                cell.detailTextLabel?.text = transferDestination?.name
            }
            return cell
        case .details(let fields):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextField", for: indexPath) as! TextFieldTableViewCell
            switch fields[indexPath.row] {
            case .amount:
                cell.textField.placeholder = "Amount"
                cell.textField.keyboardType = .decimalPad
            case .message:
                cell.textField.placeholder = "Message"
                cell.textField.keyboardType = .alphabet
            }
            return cell
        case .action:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Initiate Transfer"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        switch sections[indexPath.section] {
        case .accounts(let fields):
            switch fields[indexPath.row] {
            case .from:
                showSourceAccountPicker(cell)
            case .to:
                showTransferDestinationPicker(cell)
            }
        case .details:
            break
        case .action:
            transfer(cell)
        }
    }

    private func showSourceAccountPicker(_ sender: Any) {
        let sourceAccountPicker = SourceAccountPickerViewController()
        sourceAccountPicker.delegate = self
        show(sourceAccountPicker, sender: sender)
    }

    private func showTransferDestinationPicker(_ sender: Any) {
        guard let sourceAccount = sourceAccount else { return }

        let transferDestinationPicker = TransferDestinationPickerViewController(sourceAccount: sourceAccount)
        transferDestinationPicker.delegate = self
        show(transferDestinationPicker, sender: sender)
    }
}

extension TransferViewController: SourceAccountPickerViewControllerDelegate {
    func sourceAccountPickerViewController(_ viewController: SourceAccountPickerViewController, didSelectAccount account: Account) {
        sourceAccount = account
        navigationController?.popToViewController(self, animated: true)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}

extension TransferViewController: TransferDestinationPickerViewControllerDelegate {
    func transferDestinationPickerViewController(_ viewController: TransferDestinationPickerViewController, didSelectTransferDestination transferDestination: TransferDestination) {
        self.transferDestination = transferDestination
        navigationController?.popToViewController(self, animated: true)
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)

    }
}
