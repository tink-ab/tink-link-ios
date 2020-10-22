import Down
import TinkLink
import UIKit

/// Example of how to use the provider field specification to add credential
final class AddCredentialsViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler?
    let provider: Provider

    private let credentialsContext: CredentialsContext
    private var form: Form
    private var formError: Form.ValidationError? {
        didSet {
            tableView.reloadData()
        }
    }

    private var task: AddCredentialsTask?
    private var statusViewController: AddCredentialsStatusViewController?
    private var didFirstFieldBecomeFirstResponder = false

    private lazy var helpLabel = UITextView()

    init(provider: Provider, credentialsContext: CredentialsContext) {
        self.provider = provider
        self.form = Form(provider: provider)
        self.credentialsContext = credentialsContext

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AddCredentialsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)

        navigationItem.prompt = "Enter Credentials"
        navigationItem.title = provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        setupHelpFootnote()
        layoutHelpFootnote()
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

extension AddCredentialsViewController {
    private func setupHelpFootnote() {
        guard let helpText = provider.helpText, !helpText.isEmpty else { return }
        let markdown = Down(markdownString: helpText)
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
}

// MARK: - UITableViewDataSource

extension AddCredentialsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return form.fields.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < form.fields.count {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIdentifier, for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Add"
            cell.tintColor = form.areFieldsValid ? nil : .gray
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < form.fields.count else { return nil }

        let field = form.fields[section]
        let suffix = field.validationRules.isOptional ? " - optional" : ""

        return field.attributes.description + suffix
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section < form.fields.count else { return nil }

        let field = form.fields[section]
        if let error = formError, let fieldError = error[fieldName: field.name] {
            return fieldError.reason
        } else {
            return field.attributes.helpText
        }
    }
}

// MARK: - UITableViewDelegate

extension AddCredentialsViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section < form.fields.count {
            return false
        } else {
            return form.areFieldsValid
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < form.fields.count {
            // NOOP
        } else {
            addCredential()
        }
    }
}

// MARK: - Actions

extension AddCredentialsViewController {
    @objc private func addCredential() {
        guard task == nil else { return }

        view.endEditing(false)

        do {
            try form.validateFields()
            task = credentialsContext.add(
                for: provider,
                form: form,
                completionPredicate: .init(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false),
                progressHandler: { [weak self] status in
                    DispatchQueue.main.async {
                        self?.onUpdate(for: status)
                    }
                },
                completion: { [weak self] result in
                    DispatchQueue.main.async {
                        self?.task = nil
                        self?.onCompletion(result: result)
                    }
                }
            )
        } catch {
            formError = error as? Form.ValidationError
        }
    }

    private func onUpdate(for status: AddCredentialsTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        case .updating:
            let status = "Connecting to \(provider.displayName), please wait..."
            showUpdating(status: status)
        }
    }

    private func onCompletion(result: Result<Credentials, Error>) {
        do {
            let credential = try result.get()
            showCredentialUpdated(for: credential)
        } catch let error as ThirdPartyAppAuthenticationTask.Error {
            hideUpdatingView(animated: true) {
                self.showDownloadPrompt(for: error)
            }
        } catch {
            hideUpdatingView(animated: true) {
                self.showAlert(for: error)
            }
        }
    }
}

// MARK: - Navigation

extension AddCredentialsViewController {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        hideUpdatingView()
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showUpdating(status: String) {
        if statusViewController == nil {
            let statusViewController = AddCredentialsStatusViewController()
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

    private func showCredentialUpdated(for credential: Credentials) {
        hideUpdatingView()
        dismiss(animated: true) {
            self.onCompletion?(.success(credential))
        }
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
        let localizedError = error as? LocalizedError
        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "Error",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - TextFieldCellDelegate

extension AddCredentialsViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.section].text = text
        tableView.reloadRows(at: [IndexPath(row: 0, section: form.fields.count)], with: .none)
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

extension AddCredentialsViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credentials) {
        dismiss(animated: true)

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
}
