import UIKit
import TinkLink

protocol TransferDestinationPickerViewControllerDelegate: AnyObject {
    func transferDestinationPickerViewController(_ viewController: TransferDestinationPickerViewController, didSelectTransferDestination transferDestination: TransferDestination)
}

class TransferDestinationPickerViewController: UITableViewController {
    private let transferContext = TransferContext()

    weak var delegate: TransferDestinationPickerViewControllerDelegate?

    private let transferDestinations: [TransferDestination]
    private let selectedTransferDestination: TransferDestination?

    init(sourceAccount: Account, selectedTransferDestination: TransferDestination? = nil) {
        self.transferDestinations = sourceAccount.transferDestinations ?? []
        self.selectedTransferDestination = selectedTransferDestination
        super.init(style: .plain)
        title = "Transfer Destinations"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transferDestinations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let transferDestination = transferDestinations[indexPath.row]
        cell.textLabel?.text = transferDestination.name
        cell.accessoryType = transferDestination.uri?.value == selectedTransferDestination?.uri?.value ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transferDestination = transferDestinations[indexPath.row]
        delegate?.transferDestinationPickerViewController(self, didSelectTransferDestination: transferDestination)
    }
}
