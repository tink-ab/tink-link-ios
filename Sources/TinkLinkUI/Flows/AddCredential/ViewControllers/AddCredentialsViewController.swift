import Down
import TinkLink
import UIKit

protocol AddCredentialsViewControllerDelegate: AnyObject {
    func showScopeDescriptions()
    func showWebContent(with url: URL)
    func addCredential(provider: Provider, form: Form)
}

final class AddCredentialsViewController: UIViewController {
    let provider: Provider

    weak var delegate: AddCredentialsViewControllerDelegate?

    var prefillStrategy: TinkLinkViewController.PrefillStrategy {
        get { formTableViewController.prefillStrategy }
        set { formTableViewController.prefillStrategy = newValue }
    }

    private let credentialsController: CredentialsController
    private let clientName: String
    private let isAggregator: Bool
    private let isVerified: Bool

    private let keyboardObserver = KeyboardObserver()

    private let formTableViewController: FormTableViewController

    private lazy var helpLabel = AddCredentialsHelpTextView()
    private lazy var headerView = AddCredentialsHeaderView()
    private lazy var addCredentialFooterView = AddCredentialsFooterView()
    private lazy var gradientView = GradientView()
    private lazy var button: FloatingButton = {
        let button = FloatingButton()
        button.text = Strings.AddCredentials.Form.continue
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AddCredentialsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        view.backgroundColor = Color.background

        headerView.configure(with: provider, clientName: clientName, isAggregator: isAggregator)
        headerView.delegate = self

        formTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formTableViewController.view)
        addChild(formTableViewController)
        formTableViewController.didMove(toParent: self)

        addCredentialFooterView.delegate = self
        addCredentialFooterView.isHidden = isAggregator
        addCredentialFooterView.translatesAutoresizingMaskIntoConstraints = false
        addCredentialFooterView.backgroundColor = Color.background

        gradientView.colors = [Color.background.withAlphaComponent(0.0), Color.background]
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false

        button.addTarget(self, action: #selector(startAddCredentialsFlow), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 180)

        view.addSubview(gradientView)
        view.addSubview(addCredentialFooterView)
        view.addSubview(button)

        view.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        buttonBottomConstraint.constant = 24

        NSLayoutConstraint.activate([
            formTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            formTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            formTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),

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

        navigationItem.title = Strings.AddCredentials.Form.title
        navigationItem.largeTitleDisplayMode = .never
        button.isEnabled = formTableViewController.form.fields.filter({ $0.attributes.isEditable }).isEmpty

        setupHelpFootnote()
        layoutHelpFootnote()
        setupButton()

        formTableViewController.formDidChange = { [weak self] in
            guard let self = self else { return }
            self.button.isEnabled = self.formTableViewController.form.areFieldsValid
        }

        formTableViewController.onSubmit = { [weak self] in
            self?.addCredential()
        }

        formTableViewController.errorText = isVerified ? nil : Strings.AddCredentials.Warning.unverifiedClient
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
            button.text = Strings.AddCredentials.Form.openBankID
        default:
            button.text = Strings.AddCredentials.Form.continue
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let headerHeight = headerView.systemLayoutSizeFitting(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(249)).height
        var frame = headerView.frame
        frame.size.height = headerHeight
        formTableViewController.tableView.tableHeaderView = headerView
        formTableViewController.tableView.tableHeaderView?.frame = frame
        formTableViewController.tableView.contentInset.bottom = view.bounds.height - button.frame.minY - view.safeAreaInsets.bottom
        formTableViewController.tableView.scrollIndicatorInsets.bottom = button.rounded ? 0 : formTableViewController.tableView.contentInset.bottom
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutHelpFootnote()
    }
}

// MARK: - Help Footnote

extension AddCredentialsViewController {
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
            )
        )
    }
}

// MARK: - Keyboard Helper
extension AddCredentialsViewController {
    private func keyboardWillShow(_ notification: KeyboardNotification) {
        updateButtonBottomConstraint(notification)
    }

    private func keyboardWillHide(_ notification: KeyboardNotification) {
        resetButtonBottomConstraint(notification)
    }

    private func updateButtonBottomConstraint(_ notification: KeyboardNotification) {
        let frameHeight = notification.frame.height
        buttonBottomConstraint.constant = max(24, frameHeight - addCredentialFooterView.bounds.height)
        buttonWidthConstraint.constant = view.frame.size.width
        button.rounded = false
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
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

extension AddCredentialsViewController {
    @objc private func startAddCredentialsFlow() {
        addCredential()
    }

    private func addCredential() {
        view.endEditing(false)

        if formTableViewController.validateFields() {
            delegate?.addCredential(provider: provider, form: formTableViewController.form)
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

// MARK: - AddCredentialsHeaderViewDelegate

extension AddCredentialsViewController: AddCredentialsHeaderViewDelegate {
    func addCredentialsHeaderViewDidTapReadMore(_ addCredentialsHeaderView: AddCredentialsHeaderView) {
        showMoreInfo()
    }
}

// MARK: - AddCredentialFooterViewDelegate

extension AddCredentialsViewController: AddCredentialsFooterViewDelegate {
    func addCredentialsFooterViewDidTapLink(_ addCredentialsFooterView: AddCredentialsFooterView, url: URL) {
        showPrivacyPolicy(url)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AddCredentialsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !button.frame.contains(gestureRecognizer.location(in: view))
    }
}
