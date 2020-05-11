import UIKit
import TinkLink

class TransferViewController: UITableViewController {
    private let transferContext = TransferContext()

    var credentials: Credentials!

    init() {
        super.init(style: .insetGrouped)

        title = "Transfer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
