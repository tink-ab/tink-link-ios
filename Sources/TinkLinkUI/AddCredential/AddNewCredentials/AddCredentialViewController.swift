import Down
import TinkLinkSDK
import UIKit

/// Example of how to use the provider field specification to add credential
final class AddCredentialViewController: UITableViewController {
    
    let provider: Provider

    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    private let credentialController: CredentialController
    private var form: Form
    private var formError: Form.ValidationError? {
        didSet {
            tableView.reloadData()
        }
    }

    private var task: AddCredentialTask?
    private var statusViewController: AddCredentialStatusViewController?
    private lazy var addBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addCredential))
    private lazy var moreInfoBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showMoreInfo))
    private var didFirstFieldBecomeFirstResponder = false

    private lazy var helpLabel = UITextView()

    init(provider: Provider, credentialController: CredentialController) {
        self.provider = provider
        self.form = Form(provider: provider)
        self.credentialController = credentialController

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

extension AddCredentialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updatedStatus), name: .credentialControllerDidUpdateStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(credentialAdded), name: .credentialControllerDidAddCredential, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(supplementInformationTask), name: .credentialControllerDidSupplementInformation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedError), name: .credentialControllerDidError, object: nil)

        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false

        navigationItem.prompt = "Enter Credentials"
        navigationItem.title = provider.displayName
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [addBarButtonItem, moreInfoBarButtonItem]
        addBarButtonItem.isEnabled = form.fields.isEmpty

        toolbarItems = [
            UIBarButtonItem(title: "Terms & Conditions", style: .plain, target: self, action: #selector(showTermsAndConditions))
        ]

        setupHelpFootnote()
        layoutHelpFootnote()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didFirstFieldBecomeFirstResponder, !form.fields.isEmpty, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell {
            cell.textField.becomeFirstResponder()
            didFirstFieldBecomeFirstResponder = true
        }
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutHelpFootnote()
    }
}

// MARK: - Help Footnote

extension AddCredentialViewController {
    private func setupHelpFootnote() {

        let markdown = Down(markdownString: provider.helpText)
        helpLabel.attributedText = try? markdown.toAttributedString()
        helpLabel.backgroundColor = .clear
        helpLabel.isScrollEnabled = false
        helpLabel.isEditable = false
        if #available(iOS 13.0, *) {
            helpLabel.textColor = .secondaryLabel
        } else {
            helpLabel.textColor = .gray
        }

        let helpStackView = UIStackView(arrangedSubviews: [helpLabel])
        helpStackView.isLayoutMarginsRelativeArrangement = true

        tableView.tableFooterView = helpStackView
    }

    private func layoutHelpFootnote() {
        let footerLayoutMargins = UIEdgeInsets(top: 0, left: view.layoutMargins.left, bottom: 0, right: view.layoutMargins.right)

        let helpLabelSize = helpLabel.sizeThatFits(CGSize(width: view.bounds.inset(by: footerLayoutMargins).width, height: .infinity))

        tableView.tableFooterView?.layoutMargins = footerLayoutMargins

        tableView.tableFooterView?.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: view.bounds.width,
                height: helpLabelSize.height
            )
        )
    }

    @objc private func updatedStatus(notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo as? [String: Credential], let credential = userInfo["credential"] {
                self.showUpdating(status: credential.statusPayload)
            }
        }
    }

    @objc private func credentialAdded() {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = self.addBarButtonItem
            let addedCredential = self.credentialController.credentials.first(where: { $0.providerID == self.provider.id })
            addedCredential.flatMap { self.showCredentialUpdated(for: $0) }
        }
    }

    @objc private func supplementInformationTask() {
        DispatchQueue.main.async {
            if let task = self.credentialController.supplementInformationTask {
                self.showSupplementalInformation(for: task)
            }
        }
    }

    @objc private func receivedError(notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo as? [String: Error], let error = userInfo["error"] {
                if let error = error as? ThirdPartyAppAuthenticationTask.Error {
                    self.hideUpdatingView(animated: true) {
                        self.showDownloadPrompt(for: error)
                    }
                } else {
                    self.hideUpdatingView(animated: true) {
                        self.showAlert(for: error)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension AddCredentialViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return form.fields.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        let field = form.fields[indexPath.section]
        if let textFieldCell = cell as? TextFieldCell {
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
        let suffix = field.validationRules.isOptional ? " - optional" : ""
        
        return field.attributes.description + suffix
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

extension AddCredentialViewController {
    @objc private func addCredential(_ sender: UIBarButtonItem) {
        view.endEditing(false)

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        do {
            try form.validateFields()
            credentialController.addCredential(
                provider,
                form: form
            )
        } catch {
            formError = error as? Form.ValidationError
        }
    }

    @objc private func showMoreInfo(_ sender: UIBarButtonItem) {
        addCredentialNavigator?.showScopeDescriptions()
    }

    @objc private func showTermsAndConditions(_ sender: UIBarButtonItem) {
        addCredentialNavigator?.showTermsAndConditions()
    }
}

// MARK: - Navigation

extension AddCredentialViewController {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        hideUpdatingView()
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showUpdating(status: String) {
        if statusViewController == nil {
            navigationItem.setRightBarButton(addBarButtonItem, animated: true)
            let statusViewController = AddCredentialStatusViewController()
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

    private func hideUpdatingView(animated: Bool = false, completion: (() -> Void)? = nil) {
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

    private func showCredentialUpdated(for credential: Credential) {
        hideUpdatingView()
        dismiss(animated: true)
    }

    private func showDownloadPrompt(for thirdPartyAppAuthenticationError: ThirdPartyAppAuthenticationTask.Error) {
        let alertController = UIAlertController(title: thirdPartyAppAuthenticationError.errorDescription, message: thirdPartyAppAuthenticationError.failureReason, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthenticationError.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
                UIApplication.shared.open(appStoreURL)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
        }

        present(alertController, animated: true)
    }

    private func showAlert(for error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.section].text = text
        addBarButtonItem.isEnabled = form.areFieldsValid
    }

    func textFieldCellDidEndEditing(_ cell: TextFieldCell) {
        do {
            try form.validateFields()
        } catch {
            formError = error as? Form.ValidationError
        }
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension AddCredentialViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential) {
        dismiss(animated: true)

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
}
