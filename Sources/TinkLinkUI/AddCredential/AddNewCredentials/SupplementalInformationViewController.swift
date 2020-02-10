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

    typealias CompletionHandler = (Result<Void, Error>) -> Void
    var onCompletion: CompletionHandler?

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

        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)

        navigationItem.title = "Enter Supplemental Information"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = form.fields.isEmpty
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didFirstFieldBecomeFirstResponder, !form.fields.isEmpty, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell {
            let field = form.fields[indexPath.section]

            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.attributes.placeholder
            textFieldCell.textField.isSecureTextEntry = field.attributes.isSecureTextEntry
            textFieldCell.textField.isEnabled = field.attributes.isEditable
            textFieldCell.textField.text = field.text
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let field = form.fields[section]
        return field.attributes.description
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let field = form.fields[section]
        if let error = formError, let fieldError = error[fieldName: field.name] {
            return fieldError.errorDescription
        } else {
            return field.attributes.helpText
        }
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

extension SupplementalInformationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            form.fields[indexPath.section].text = text
            navigationItem.rightBarButtonItem?.isEnabled = form.fields[indexPath.section].isValid
        }
    }

    func textFieldCellDidEndEditing(_ cell: TextFieldCell) {
        do {
            try form.validateFields()
        } catch {
            formError = error as? Form.ValidationError
        }
    }
}
