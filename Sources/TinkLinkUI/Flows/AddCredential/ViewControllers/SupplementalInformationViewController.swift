import TinkLink
import UIKit

protocol SupplementalInformationViewControllerDelegate: AnyObject {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController)
    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didPressSubmitWithForm form: Form)
}

/// Example of how to use the credential field supplemental information to update credential
final class SupplementalInformationViewController: UIViewController {

    weak var delegate: SupplementalInformationViewControllerDelegate?

    private let button = FloatingButton()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let keyboardObserver = KeyboardObserver()

    private var form: Form
    private var errors: [IndexPath: Form.Field.ValidationError] = [:]

    private lazy var buttonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor)
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(equalToConstant: button.minimumWidth)
    private var didFirstFieldBecomeFirstResponder = false

    init(supplementInformationTask: SupplementInformationTask) {
        self.form = Form(credentials: supplementInformationTask.credentials)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension SupplementalInformationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        tableView.registerReusableCell(ofType: FormFieldTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self

        keyboardObserver.willShow = { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        keyboardObserver.willHide = { [weak self] notification in
            self?.keyboardWillHide(notification)
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = form.fields.filter({ $0.attributes.isEditable }).isEmpty
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.text = NSLocalizedString("AddCredentials.SupplementalInformation.Cancel", tableName: "TinkLinkUI", value: "Done", comment: "Title for button to send supplemental information when adding credentials.")

        navigationItem.title = NSLocalizedString("AddCredentials.SupplementalInformation.Title", tableName: "TinkLinkUI", value: "Supplemental Information", comment: "Title for form asking user to supplement information when adding credentials.")
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))

        view.addSubview(tableView)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBottomConstraint,
            buttonWidthConstraint,
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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

extension SupplementalInformationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = form.fields[indexPath.row]
        let cell = tableView.dequeueReusableCell(ofType: FormFieldTableViewCell.self, for: indexPath)
        cell.delegate = self
        cell.configure(with: field)
        cell.setError(with: errors[indexPath]?.localizedDescription)
        return cell
    }
}

// MARK: - Actions

extension SupplementalInformationViewController {
    @objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.supplementalInformationViewControllerDidCancel(self)
    }

    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        tableView.resignFirstResponder()

        var indexPathsToUpdate = Set(errors.keys)
        errors = [:]

        do {
            try form.validateFields()
            delegate?.supplementalInformationViewController(self, didPressSubmitWithForm: form)
        } catch let error as Form.ValidationError {
            for (index, field) in form.fields.enumerated() {
                guard let error = error[fieldName: field.name] else {
                    continue
                }
                let indexPath = IndexPath(row: index, section: 0)
                errors[indexPath] = error
                indexPathsToUpdate.insert(indexPath)
            }
        } catch {
            assertionFailure("validateFields should only throw Form.ValidationError")
        }

        tableView.reloadRows(at: Array(indexPathsToUpdate), with: .automatic)
    }
}

// MARK: - TextFieldCellDelegate

extension SupplementalInformationViewController: FormFieldTableViewCellDelegate {
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool {
        // TODO: Fix this
        return true
    }

    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.item].text = text
        errors[indexPath] = nil
        tableView.beginUpdates()
        cell.setError(with: nil)
        tableView.endUpdates()
        button.isEnabled = form.fields[indexPath.item].isValid
    }

    func formFieldCellDidEndEditing(_ cell: FormFieldTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let field = form.fields[indexPath.item]

        do {
            try field.validate()
            errors[indexPath] = nil
        } catch let error as Form.Field.ValidationError {
            errors[indexPath] = error
        } catch {
            print("Unknown error \(error).")
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Keyboard Helper
extension SupplementalInformationViewController {
    private func keyboardWillShow(_ notification: KeyboardNotification) {
        let keyboardHeight = notification.frame.height
        buttonBottomConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom
        buttonWidthConstraint.constant = view.frame.size.width
        button.rounded = false
        view.layoutIfNeeded()
    }

    private func keyboardWillHide(_ notification: KeyboardNotification) {
        buttonBottomConstraint.constant = 4
        button.rounded = true
        buttonWidthConstraint.constant = button.minimumWidth
        view.layoutIfNeeded()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SupplementalInformationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !button.frame.contains(gestureRecognizer.location(in: view))
    }
}
