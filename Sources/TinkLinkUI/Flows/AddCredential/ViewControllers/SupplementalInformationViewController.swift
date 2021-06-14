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

    private var viewConstraints: [NSLayoutConstraint] = []
    private lazy var buttonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor)
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: button.minimumWidth)

    init(supplementInformationTask: SupplementInformationTask) {
        let form = Form(supplementInformationTask: supplementInformationTask)
        self.formTableViewController = FormTableViewController(form: form)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension SupplementalInformationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        formTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formTableViewController.view)
        addChild(formTableViewController)
        formTableViewController.didMove(toParent: self)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.text = Strings.SupplementalInformation.submit

        navigationItem.title = Strings.SupplementalInformation.title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))

        view.addSubview(button)

        NSLayoutConstraint.activate([
            formTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            formTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            formTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        setupButtonConstraints()

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

        formTableViewController.additionalSafeAreaInsets.bottom = button.rounded ? 0 : view.bounds.height - button.frame.minY - view.safeAreaInsets.bottom
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupButtonConstraints()
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
        if UIDevice.current.isPad || UIDevice.current.isLandscape {
            updateHorizontalButtonConstraint(notification)
        } else {
            updateVerticalButtonConstraint(notification)
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

    private func updateVerticalButtonConstraint(_ notification: KeyboardNotification) {
        let keyboardHeight = notification.frame.height
        buttonBottomConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom
        buttonWidthConstraint.constant = view.frame.size.width
        button.rounded = false
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateHorizontalButtonConstraint(_ notification: KeyboardNotification) {
        let keyboardHeight = notification.frame.height
        let constant: CGFloat = UIDevice.current.isPad ? 40 : 16
        if UIDevice.current.isLandscape {
            buttonBottomConstraint.constant = keyboardHeight - constant
        } else {
            buttonBottomConstraint.constant = keyboardHeight - 120
        }
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

// MARK: - Constraints

extension SupplementalInformationViewController {
    private func setupButtonConstraints() {
        NSLayoutConstraint.deactivate(viewConstraints)
        viewConstraints.removeAll()

        buttonBottomConstraint.constant = 24
        let buttonPositionConstraint: NSLayoutConstraint

        if UIDevice.current.isPad || UIDevice.current.isLandscape {
            buttonPositionConstraint = button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        } else {
            buttonPositionConstraint = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        }

        viewConstraints.append(contentsOf: [
            buttonBottomConstraint,
            buttonWidthConstraint,
            buttonPositionConstraint
        ])

        NSLayoutConstraint.activate(viewConstraints)
    }
}
