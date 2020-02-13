import TinkLinkSDK
import UIKit

protocol SupplementalInformationViewControllerDelegate: AnyObject {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController)
    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential)
}

/// Example of how to use the credential field supplemental information to update credential
final class SupplementalInformationViewController: UITableViewController {
    let supplementInformationTask: SupplementInformationTask

    weak var delegate: SupplementalInformationViewControllerDelegate?

    private var form: Form
    private var formError: Form.ValidationError? {
        didSet {
            tableView.reloadData()
        }
    }

    private var didFirstFieldBecomeFirstResponder = false

    init(supplementInformationTask: SupplementInformationTask) {
        self.supplementInformationTask = supplementInformationTask
        self.form = Form(credential: supplementInformationTask.credential)

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension SupplementalInformationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: FormFieldTableViewCell.reuseIdentifier)

        navigationItem.title = "Enter Supplemental Information"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = form.fields.isEmpty
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didFirstFieldBecomeFirstResponder, !form.fields.isEmpty, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FormFieldTableViewCell {
            cell.textField.becomeFirstResponder()
            didFirstFieldBecomeFirstResponder = true
        }
    }
}

// MARK: - UITableViewDataSource

extension SupplementalInformationViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return form.fields.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldTableViewCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? FormFieldTableViewCell {
            let field = form.fields[indexPath.section]

            textFieldCell.delegate = self
            textFieldCell.configure(field: field)
        }
        return cell
    }
}

// MARK: - Actions

extension SupplementalInformationViewController {
    @objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
        supplementInformationTask.cancel()
        delegate?.supplementalInformationViewControllerDidCancel(self)
    }

    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        tableView.resignFirstResponder()
        do {
            try form.validateFields()
            supplementInformationTask.submit(form)
            delegate?.supplementalInformationViewController(self, didSupplementInformationForCredential: supplementInformationTask.credential)
        } catch {
            formError = error as? Form.ValidationError
        }
    }
}

// MARK: - TextFieldCellDelegate

extension SupplementalInformationViewController: FormFieldTableViewCellDelegate {
    func textFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            form.fields[indexPath.section].text = text
            navigationItem.rightBarButtonItem?.isEnabled = form.fields[indexPath.section].isValid
        }
    }

    func textFieldCellDidEndEditing(_ cell: FormFieldTableViewCell) {
        do {
            try form.validateFields()
        } catch {
            formError = error as? Form.ValidationError
        }
    }
}
