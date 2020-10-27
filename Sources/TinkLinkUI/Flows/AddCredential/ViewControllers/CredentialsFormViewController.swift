import Down
import TinkLink
import UIKit
import Kingfisher

protocol CredentialsFormViewControllerDelegate: AnyObject {
    func showScopeDescriptions()
    func showWebContent(with url: URL)
    func submit(form: Form)
}

final class CredentialsFormViewController: UIViewController {
    let provider: Provider

    weak var delegate: CredentialsFormViewControllerDelegate?

    var prefillStrategy: TinkLinkViewController.PrefillStrategy {
        get { formTableViewController.prefillStrategy }
        set { formTableViewController.prefillStrategy = newValue }
    }

    private let credentialsController: CredentialsController
    private var form: Form {
        formTableViewController.form
    }

    private let clientName: String
    private let isAggregator: Bool
    private let isVerified: Bool

    private let keyboardObserver = KeyboardObserver()

    private let formTableViewController: FormTableViewController
    private lazy var emptyView = EmptyFormView(imageURL: provider.image, text: provider.displayName, errorText: errorText)
    private lazy var tinkIconView: UIImageView = {
        let tinkIconView = UIImageView()
        tinkIconView.image = UIImage(icon: .tink)
        tinkIconView.contentMode = .scaleAspectFit
        return tinkIconView
    }()

    private var errorText: String? {
        isVerified ? nil : Strings.Credentials.unverifiedClient
    }

    private lazy var navigationTitleView = NavigationTitleImageView(imageURL: provider.image, text: provider.displayName)
    private lazy var helpLabel = ProviderHelpTextView()
    private lazy var addCredentialFooterView = AddCredentialsFooterView()
    private lazy var gradientView = GradientView()
    private lazy var button: FloatingButton = {
        let button = FloatingButton()
        button.text = Strings.Generic.continue
        return button
    }()

    private lazy var buttonBottomConstraint = addCredentialFooterView.topAnchor.constraint(equalTo: button.bottomAnchor)
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: button.minimumWidth)

    init(provider: Provider, credentialsController: CredentialsController, clientName: String, isAggregator: Bool, isVerified: Bool) {
        self.provider = provider
        let form = Form(provider: provider)
        self.formTableViewController = FormTableViewController(form: form)
        self.credentialsController = credentialsController
        self.clientName = clientName
        self.isAggregator = isAggregator
        self.isVerified = isVerified

        super.init(nibName: nil, bundle: nil)
    }

    init(credentials: Credentials, provider: Provider, credentialsController: CredentialsController, clientName: String, isAggregator: Bool, isVerified: Bool) {
        self.provider = provider
        let form = Form(updatingCredentials: credentials, provider: provider)
        self.formTableViewController = FormTableViewController(form: form)
        self.credentialsController = credentialsController
        self.clientName = clientName
        self.isAggregator = isAggregator
        self.isVerified = isVerified

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension CredentialsFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        view.backgroundColor = Color.background

        tinkIconView.translatesAutoresizingMaskIntoConstraints = false
        tinkIconView.isHidden = isAggregator

        let fieldsView: UIView
        if form.fields.isEmpty {
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyView)

            fieldsView = emptyView
        } else {
            formTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(formTableViewController.view)
            addChild(formTableViewController)
            formTableViewController.didMove(toParent: self)
            formTableViewController.onSubmit = { [weak self] in
                self?.addCredential()
            }
            formTableViewController.errorText = errorText

            fieldsView = formTableViewController.view
        }

        addCredentialFooterView.delegate = self
        addCredentialFooterView.configure(clientName)
        addCredentialFooterView.isHidden = isAggregator
        addCredentialFooterView.translatesAutoresizingMaskIntoConstraints = false
        addCredentialFooterView.backgroundColor = Color.background

        gradientView.colors = [Color.background.withAlphaComponent(0.0), Color.background]
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false

        button.addTarget(self, action: #selector(startAddCredentialsFlow), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        navigationTitleView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tinkIconView)
        view.addSubview(gradientView)
        view.addSubview(addCredentialFooterView)
        view.addSubview(button)

        view.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        buttonBottomConstraint.constant = 24

        NSLayoutConstraint.activate([
            tinkIconView.widthAnchor.constraint(equalToConstant: 40),
            tinkIconView.heightAnchor.constraint(equalToConstant: 20),
            tinkIconView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            tinkIconView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),

            fieldsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fieldsView.topAnchor.constraint(equalTo: view.topAnchor),
            fieldsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fieldsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addCredentialFooterView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            addCredentialFooterView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addCredentialFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: button.topAnchor, constant: -40),
            gradientView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: addCredentialFooterView.topAnchor),

            buttonWidthConstraint,
            button.heightAnchor.constraint(equalToConstant: 48),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonBottomConstraint,
        ])
        navigationItem.titleView = navigationTitleView
        navigationItem.largeTitleDisplayMode = .never

        setupHelpFootnote()
        layoutHelpFootnote()
        setupButton()
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

    func setupButton() {
        switch provider.credentialsKind {
        case .mobileBankID:
            button.image = UIImage(icon: .bankID)
            button.text = Strings.Credentials.openBankID
        default:
            button.text = Strings.Generic.login
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        formTableViewController.additionalSafeAreaInsets.bottom = view.bounds.height - button.frame.minY - view.safeAreaInsets.bottom
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutHelpFootnote()
    }
}

// MARK: - Help Footnote

extension CredentialsFormViewController {
    private func setupHelpFootnote() {
        guard let helpText = provider.helpText, !helpText.isEmpty else { return }
        helpLabel.configure(markdownString: helpText)
        formTableViewController.tableView.tableFooterView = helpLabel
    }

    private func layoutHelpFootnote() {
        guard let footerView = formTableViewController.tableView.tableFooterView else {
            return
        }

        let footerSize = footerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        footerView.frame = CGRect(origin: .zero, size: CGSize(
            width: view.bounds.width,
            height: footerSize.height
        ))
    }
}

// MARK: - Keyboard Helper

extension CredentialsFormViewController {
    private func keyboardWillShow(_ notification: KeyboardNotification) {
        updateButtonBottomConstraint(notification)
    }

    private func keyboardWillHide(_ notification: KeyboardNotification) {
        resetButtonBottomConstraint(notification)
    }

    private func updateButtonBottomConstraint(_ notification: KeyboardNotification) {
        if let window = view.window {
            let keyboardFrameHeight = addCredentialFooterView.frame.minY - window.convert(notification.frame, to: view).minY
            buttonBottomConstraint.constant = max(24, keyboardFrameHeight)
            buttonWidthConstraint.constant = view.frame.size.width
            button.rounded = false
            UIView.animate(withDuration: notification.duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func resetButtonBottomConstraint(_ notification: KeyboardNotification) {
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

// MARK: - Actions

extension CredentialsFormViewController {
    @objc private func startAddCredentialsFlow() {
        addCredential()
    }

    private func addCredential() {
        if formTableViewController.validateFields() {
            view.endEditing(false)
            delegate?.submit(form: formTableViewController.form)
        }
    }

    private func showMoreInfo() {
        delegate?.showScopeDescriptions()
    }

    private func showTermsAndConditions(_ url: URL) {
        delegate?.showWebContent(with: url)
    }

    private func showPrivacyPolicy(_ url: URL) {
        delegate?.showWebContent(with: url)
    }
}

// MARK: - AddCredentialFooterViewDelegate

extension CredentialsFormViewController: AddCredentialsFooterViewDelegate {
    func addCredentialsFooterViewDidTapLink(_ addCredentialsFooterView: AddCredentialsFooterView, url: URL) {
        showPrivacyPolicy(url)
    }

    func addCredentialsFooterViewDidTapConsentReadMoreLink(_ addCredentialsFooterView: AddCredentialsFooterView) {
        showMoreInfo()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CredentialsFormViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !button.frame.contains(gestureRecognizer.location(in: view))
    }
}
