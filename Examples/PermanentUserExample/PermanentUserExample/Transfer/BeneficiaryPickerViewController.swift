import UIKit
import TinkLink

protocol BeneficiaryPickerViewControllerDelegate: AnyObject {
    func beneficiaryPickerViewController(_ viewController: BeneficiaryPickerViewController, didSelectBeneficiary beneficiary: TransferAccountIdentifiable)
}

class BeneficiaryPickerViewController: UITableViewController {
    private let transferContext = TransferContext()

    weak var delegate: BeneficiaryPickerViewControllerDelegate?

    private let sourceAccount: Account
    private var beneficiaries: [Beneficiary]
    private let selectedBeneficiary: Beneficiary?
    private var canceller: RetryCancellable?
    private var addBeneficiaryTask: AddBeneficiaryTask?
    private var statusViewController: StatusViewController?

    init(sourceAccount: Account, selectedBeneficiary: Beneficiary? = nil) {
        self.sourceAccount = sourceAccount
        self.beneficiaries = []
        self.selectedBeneficiary = selectedBeneficiary
        super.init(style: .plain)
        title = "Select Beneficiary"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        addBeneficiaryTask?.cancel()
    }
}

// MARK: - View Lifecycle

extension BeneficiaryPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(enterBeneficiary)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBeneficiary(_:))),
        ]

        canceller = transferContext.fetchBeneficiaries(for: sourceAccount) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.beneficiaries = try result.get()
                    self?.tableView.reloadData()
                } catch {
                    self?.showAlert(for: error)
                }
            }
        }

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - Actions

extension BeneficiaryPickerViewController {
    @objc private func enterBeneficiary(_ sender: Any) {
        let alert = UIAlertController(title: "Enter Beneficiary URI", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Type"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addTextField { textField in
            textField.placeholder = "Account Number"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addTextField { textField in
            textField.placeholder = "Optional - Name"
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            guard let kind = alert.textFields?[0].text,
                let accountNumber = alert.textFields?[1].text
            else { return }
            let name = alert.textFields?[2].text ?? ""
            let beneficiaryAccount = BeneficiaryAccount(accountNumberKind: AccountNumberKind(kind), accountNumber: accountNumber, name: name.isEmpty ? nil : name)
            self.delegate?.beneficiaryPickerViewController(self, didSelectBeneficiary: beneficiaryAccount)
        }))
        present(alert, animated: true)
    }

    @objc private func addBeneficiary(_ sender: Any) {
        let alert = UIAlertController(title: "Add Beneficiary", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }
        alert.addTextField { textField in
            textField.placeholder = "Type"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addTextField { textField in
            textField.placeholder = "Account Number"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addTextField { textField in
            textField.placeholder = "Optional - Credentials ID"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let name = alert.textFields?[0].text,
                let accountNumberKind = alert.textFields?[1].text,
                let accountNumber = alert.textFields?[2].text
            else { return }
            let credentialsID = alert.textFields?[3].text ?? ""
            self.addBeneficiary(account: BeneficiaryAccount(accountNumberKind: AccountNumberKind(accountNumberKind), accountNumber: accountNumber), name: name, credentialsID: credentialsID.isEmpty ? nil : credentialsID)
        }))
        present(alert, animated: true)
    }
}

// MARK: - Adding a Beneficiary

extension BeneficiaryPickerViewController {
    private func addBeneficiary(account: BeneficiaryAccount, name: String, credentialsID: String?) {
        addBeneficiaryTask = transferContext.addBeneficiary(
            account: account,
            name: name,
            toAccountWithID: sourceAccount.id,
            onCredentialsWithID: credentialsID.map { Credentials.ID($0) } ?? sourceAccount.credentialsID,
            authentication: { [weak self] task in
                DispatchQueue.main.async {
                    self?.handleAddBeneficiaryAuthentication(task)
                }
            },
            progress: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleAddBeneficiaryProgress(status)
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    do {
                        _ = try result.get()
                        self?.hideStatus(animated: true) {
                            let alert = UIAlertController(title: "The request for adding the beneficiary has been sent successfully", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                    } catch {
                        self?.hideStatus(animated: true) {
                            self?.showAlert(for: error)
                        }
                    }
                }
            }
        )
    }

    private func handleAddBeneficiaryAuthentication(_ authenticationTask: AuthenticationTask) {
        switch authenticationTask {
        case .awaitingSupplementalInformation(let task):
            hideStatus(animated: false) {
                self.showSupplementalInformation(for: task)
            }
        case .awaitingThirdPartyAppAuthentication(let task):
            task.handle()
        }
    }

    private func handleAddBeneficiaryProgress(_ status: AddBeneficiaryTask.Status) {
        switch status {
        case .requestSent:
            showStatus("Request sent")
        case .authenticating:
            showStatus("Authenticating…")
        case .updating(let status):
            showStatus(status)
        }
    }

    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showStatus(_ status: String) {
        if statusViewController == nil {
            let statusViewController = StatusViewController()
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
}

// MARK: - UITableViewDataSource

extension BeneficiaryPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beneficiaries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let beneficiary = beneficiaries[indexPath.row]
        cell.textLabel?.text = beneficiary.name
        cell.detailTextLabel?.text = "\(beneficiary.accountNumberKind.value): \(beneficiary.accountNumber)"
        cell.accessoryType = beneficiary == selectedBeneficiary ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beneficiary = beneficiaries[indexPath.row]
        delegate?.beneficiaryPickerViewController(self, didSelectBeneficiary: beneficiary)
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension BeneficiaryPickerViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credentials) {
        dismiss(animated: true)
    }
}
