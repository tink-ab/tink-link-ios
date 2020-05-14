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
    private let formTableViewController: FormTableViewController
    private let keyboardObserver = KeyboardObserver()

    private lazy var buttonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor)
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: button.minimumWidth)

    init(supplementInformationTask: SupplementInformationTask) {
        let form = Form(credentials: supplementInformationTask.credentials)
        self.formTableViewController = FormTableViewController(form: form)
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

        formTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formTableViewController.view)
        addChild(formTableViewController)
        formTableViewController.didMove(toParent: self)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = formTableViewController.form.fields.filter({ $0.attributes.isEditable }).isEmpty
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.text = Strings.SupplementalInformation.Form.submit

        navigationItem.title = Strings.SupplementalInformation.Form.title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))

        view.addSubview(button)

        buttonBottomConstraint.constant = 24

        NSLayoutConstraint.activate([
            formTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            formTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            formTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBottomConstraint,
            buttonWidthConstraint,
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        formTableViewController.formDidChange = { [weak self] in
            guard let self = self else { return }
            self.button.isEnabled = self.formTableViewController.form.areFieldsValid
        }

        formTableViewController.onSubmit = { [weak self] in
            self?.submit()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        keyboardObserver.willShow = { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        keyboardObserver.willHide = { [weak self] notification in
            self?.keyboardWillHide(notification)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        formTableViewController.tableView.contentInset.top = 16.0
        formTableViewController.tableView.contentInset.bottom = view.bounds.height - button.frame.minY - view.safeAreaInsets.bottom
        formTableViewController.tableView.scrollIndicatorInsets.bottom = button.rounded ? 0 : formTableViewController.tableView.contentInset.bottom
    }
}

// MARK: - Actions

extension SupplementalInformationViewController {
    @objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.supplementalInformationViewControllerDidCancel(self)
    }

    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        submit()

    }

    func submit() {
        if formTableViewController.validateFields() {
            delegate?.supplementalInformationViewController(self, didPressSubmitWithForm: formTableViewController.form)
        }
    }
}

// MARK: - Keyboard Helper
extension SupplementalInformationViewController {
    private func keyboardWillShow(_ notification: KeyboardNotification) {
        let keyboardHeight = notification.frame.height
        buttonBottomConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom
        buttonWidthConstraint.constant = view.frame.size.width
        button.rounded = false
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func keyboardWillHide(_ notification: KeyboardNotification) {
        buttonBottomConstraint.constant = 24
        buttonWidthConstraint.constant = button.minimumWidth
        button.rounded = true
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
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
