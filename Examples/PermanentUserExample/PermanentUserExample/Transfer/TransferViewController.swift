import UIKit
import TinkLink

class TransferViewController: UITableViewController {
    private let transferContext = TransferContext()

    var credentials: Credentials!

    private var sourceAccounts: [Account]? = nil

    private enum Section {
        enum DetailField {
            case amount
            case message
        }
        case details([DetailField])
        case action
    }

    private let sections: [Section] = [.details([.amount, .message]), .action]

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

        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextField")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "Button")

        transferContext.sourceAccounts { [weak self] (result) in
            self?.sourceAccounts = try? result.get()
        }
    }

    @objc private func transfer(_ sender: Any) {
        _ = transferContext.initiateTransfer(
            amount: ExactNumber(value: 1),
            currencyCode: "EUR",
            credentials: credentials,
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
        case .details(let items):
            return items.count
        case .action:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
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
            cell.actionLabel.text = "Transfer"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        transfer(cell)
    }
}
