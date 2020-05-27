import UIKit
import TinkLink

class TransferViewController: UITableViewController {
    private let transferContext = TransferContext()

    private var sourceAccount: Account?
    private var beneficiary: Beneficiary?
    private var amount: Decimal?
    private var message = ""

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

    private var initiateTransferTask: InitiateTransferTask?

    private var statusViewController: AddCredentialsStatusViewController?

    init() {
        super.init(style: .insetGrouped)

        title = "Transfer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension TransferViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(Value2TableViewCell.self, forCellReuseIdentifier: "Value2")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextField")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "Button")
    }
}

// MARK: - Actions

extension TransferViewController {
    @objc private func transfer(_ sender: Any) {
        guard
            let sourceAccount = sourceAccount,
            let transferDestination = beneficiary,
            let balance = sourceAccount.currencyDenominatedBalance,
            let amount = amount
            else { return }

        initiateTransferTask = transferContext.initiateTransfer(
            from: sourceAccount,
            to: transferDestination,
            amount: CurrencyDenominatedAmount(value: amount, currencyCode: balance.currencyCode),
            message: .init(destination: message),
            authentication: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleTransferAuthentication(status)
                }
            },
            progress: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleTransferProgress(status)
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleTransferCompletion(result)
                }
            }
        )
    }

    @objc private func cancel(_ sender: Any) {
        initiateTransferTask?.cancel()
        dismiss(animated: true)
    }

    @objc private func cancelQRCode(_ sender: Any) {
        initiateTransferTask?.cancel()
        dismiss(animated: true)
    }
}

// MARK: - Transfer Handling

extension TransferViewController {
    private func handleTransferProgress(_ status: InitiateTransferTask.Status) {
        switch status {
        case .created:
            showStatus("Created")
        case .authenticating:
            showStatus("Authenticating…")
        case .executing(let status):
            showStatus(status)
        }
    }

    private func handleTransferAuthentication(_ authenticationTask: InitiateTransferTask.AuthenticationTask) {
        switch authenticationTask {
        case .awaitingSupplementalInformation(let task):
            hideStatus(animated: false) {
                self.showSupplementalInformation(for: task)
            }
        case .awaitingThirdPartyAppAuthentication(let task):
            task.handle()
        }
    }

    private func handleTransferCompletion(_ result: Result<InitiateTransferTask.Receipt, Error>) {
        hideStatus(animated: true) {
            do {
                let receipt = try result.get()
                self.showTransferSuccess(receipt)
            } catch {
                self.showAlert(for: error)
            }
        }
        initiateTransferTask = nil
    }
}

// MARK: - UITableViewDataSource

extension TransferViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .accounts(let fields):
            return fields.count
        case .details(let fields):
            return fields.count
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
                cell.detailTextLabel?.text = beneficiary?.name
            }
            return cell
        case .details(let fields):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextField", for: indexPath) as! TextFieldTableViewCell
            cell.delegate = self
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
}

// MARK: - UITableViewDelegate

extension TransferViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch sections[indexPath.section] {
        case .accounts(let fields):
            switch fields[indexPath.row] {
            case .from:
                return true
            case .to:
                return sourceAccount != nil
            }
        case .details:
            return false
        case .action:
            return initiateTransferTask == nil
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
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Navigation

extension TransferViewController {
    private func showSourceAccountPicker(_ sender: Any) {
        let sourceAccountPicker = SourceAccountPickerViewController(selectedAccount: sourceAccount)
        sourceAccountPicker.delegate = self
        show(sourceAccountPicker, sender: sender)
    }

    private func showTransferDestinationPicker(_ sender: Any) {
        guard let sourceAccount = sourceAccount else { return }

        let transferDestinationPicker = BeneficiaryPickerViewController(sourceAccount: sourceAccount, selectedBeneficiary: beneficiary)
        transferDestinationPicker.delegate = self
        show(transferDestinationPicker, sender: sender)
    }

    private func showStatus(_ status: String) {
        if statusViewController == nil {
            let statusViewController = AddCredentialsStatusViewController()
            statusViewController.modalTransitionStyle = .crossDissolve
            statusViewController.modalPresentationStyle = .overFullScreen
            present(statusViewController, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.view.tintAdjustmentMode = .dimmed
            }
            self.statusViewController = statusViewController
        }
        statusViewController?.status = status
    }

    private func hideStatus(animated: Bool, completion: (() -> Void)? = nil) {
        guard statusViewController != nil else {
            completion?()
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.view.tintAdjustmentMode = .automatic
        }
        dismiss(animated: animated, completion: completion)
        statusViewController = nil
    }

    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showQR(_ image: UIImage) {
        let qrViewController = QRViewController(image: image)
        qrViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancelQRCode))
        let navigationController = UINavigationController(rootViewController: qrViewController)
        present(navigationController, animated: true)
    }

    private func showTransferSuccess(_ receipt: InitiateTransferTask.Receipt) {
        let alert = UIAlertController(title: "Success", message: receipt.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showAlert(for error: Error) {
        let localizedError = error as? LocalizedError
        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "Error",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - TextFieldTableViewCellDelegate

extension TransferViewController: TextFieldTableViewCellDelegate {
    func textFieldTableViewCell(_ cell: TextFieldTableViewCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        switch sections[indexPath.section] {
        case .details(let fields):
            switch fields[indexPath.row] {
            case .amount:
                amount = Decimal(string: text)
            case .message:
                message = text
            }
        default:
            break
        }
    }

    func textFieldTableViewCellDidEndEditing(_ cell: TextFieldTableViewCell) {

    }
}

// MARK: - SourceAccountPickerViewControllerDelegate

extension TransferViewController: SourceAccountPickerViewControllerDelegate {
    func sourceAccountPickerViewController(_ viewController: SourceAccountPickerViewController, didSelectAccount account: Account) {
        sourceAccount = account
        navigationController?.popToViewController(self, animated: true)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}

// MARK: - TransferDestinationPickerViewControllerDelegate

extension TransferViewController: BeneficiaryPickerViewControllerDelegate {
    func beneficiaryPickerViewController(_ viewController: BeneficiaryPickerViewController, didSelectBeneficiary beneficiary: Beneficiary) {
        self.beneficiary = beneficiary
        navigationController?.popToViewController(self, animated: true)
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }

    func beneficiaryPickerViewController(_ viewController: BeneficiaryPickerViewController, didEnterBeneficiaryURI beneficiaryURI: Beneficiary.URI) {
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension TransferViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credentials) {
        dismiss(animated: true)
    }
}
