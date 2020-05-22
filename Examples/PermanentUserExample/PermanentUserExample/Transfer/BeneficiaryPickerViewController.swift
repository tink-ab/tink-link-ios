import UIKit
import TinkLink

protocol BeneficiaryPickerViewControllerDelegate: AnyObject {
    func beneficiaryPickerViewController(_ viewController: BeneficiaryPickerViewController, didSelectBeneficiary beneficiary: Beneficiary)
}

class BeneficiaryPickerViewController: UITableViewController {
    private let transferContext = TransferContext()

    weak var delegate: BeneficiaryPickerViewControllerDelegate?

    private let sourceAccount: Account
    private var beneficiaries: [Beneficiary]
    private let selectedBeneficiary: Beneficiary?
    private var canceller: RetryCancellable?

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

    override func viewDidLoad() {
        super.viewDidLoad()

        canceller = transferContext.fetchBeneficiaries(for: sourceAccount) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.beneficiaries = try result.get()
                    self?.tableView.reloadData()
                } catch {
                    // Handle any error
                }
            }
        }

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beneficiaries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let beneficiary = beneficiaries[indexPath.row]
        cell.textLabel?.text = beneficiary.name
        cell.detailTextLabel?.text = beneficiary.accountNumber
        cell.accessoryType = beneficiary == selectedBeneficiary ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beneficiary = beneficiaries[indexPath.row]
        delegate?.beneficiaryPickerViewController(self, didSelectBeneficiary: beneficiary)
    }
}
