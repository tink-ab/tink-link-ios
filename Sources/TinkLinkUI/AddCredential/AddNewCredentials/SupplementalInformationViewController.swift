import TinkLinkSDK
import UIKit

protocol SupplementalInformationViewControllerDelegate: AnyObject {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController)
    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential)
}

/// Example of how to use the credential field supplemental information to update credential
final class SupplementalInformationViewController: UIViewController {

    weak var delegate: SupplementalInformationViewControllerDelegate?

    private let button = FloatingButton()
    private let tableView = UITableView(frame: .zero, style: .plain)

    let supplementInformationTask: SupplementInformationTask
    private var form: Form
    private var formError: Form.ValidationError?

    private lazy var buttonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor)
    private var didFirstFieldBecomeFirstResponder = false

    init(supplementInformationTask: SupplementInformationTask) {
        self.supplementInformationTask = supplementInformationTask
        self.form = Form(credential: supplementInformationTask.credential)
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

        tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: FormFieldTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.text = "Done"

        navigationItem.title = "Supplemental Information"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldTableViewCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? FormFieldTableViewCell {
            let field = form.fields[indexPath.row]

            textFieldCell.delegate = self
            textFieldCell.configure(with: field)
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
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool {
        // TODO: Fix this
        return true
    }

    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            form.fields[indexPath.section].text = text
            navigationItem.rightBarButtonItem?.isEnabled = form.fields[indexPath.section].isValid
        }
    }

    func formFieldCellDidEndEditing(_ cell: FormFieldTableViewCell) {
        do {
            try form.validateFields()
        } catch {
            formError = error as? Form.ValidationError
        }
    }
}

// MARK: - Keyboard Helper
extension SupplementalInformationViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            buttonBottomConstraint.constant = keyboardHeight + 4 - view.safeAreaInsets.bottom
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        buttonBottomConstraint.constant = 4
    }
}
