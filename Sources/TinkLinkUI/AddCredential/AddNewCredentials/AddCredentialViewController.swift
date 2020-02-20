import Down
import TinkLinkSDK
import UIKit

/// Example of how to use the provider field specification to add credential
final class AddCredentialViewController: UIViewController {
    let provider: Provider
    var username: String? {
        credentialController.user?.username
    }

    weak var addCredentialNavigator: AddCredentialFlowNavigating?

    private let credentialController: CredentialController
    private let isAggregator: Bool
    private var form: Form
    private var errors: [IndexPath: Form.Field.ValidationError] = [:]

    private var task: AddCredentialTask?
    private var statusViewController: AddCredentialStatusViewController?
    private var qrImageViewController: QRImageViewController?
    private var statusPresentationManager = AddCredentialStatusPresentationManager()
    private var didFirstFieldBecomeFirstResponder = false

    private lazy var tableView = UITableView(frame: .zero, style: .grouped)
    private lazy var helpLabel = UITextView()
    private lazy var headerView = AddCredentialHeaderView()
    private lazy var addCredentialFooterView = AddCredentialFooterView()

    init(provider: Provider, credentialController: CredentialController, isAggregator: Bool) {
        self.provider = provider
        self.form = Form(provider: provider)
        self.credentialController = credentialController
        self.isAggregator = isAggregator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        task?.cancel()
    }
}

// MARK: - View Lifecycle

extension AddCredentialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

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

        tableView.delegate = self
        tableView.dataSource = self

        headerView.configure(with: provider, username: username, isAggregator: isAggregator)
        headerView.delegate = self

        tableView.backgroundColor = .clear
        tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: FormFieldTableViewCell.reuseIdentifier)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addCredentialFooterView.delegate = self
        addCredentialFooterView.configure(with: provider, isAggregator: isAggregator)
        addCredentialFooterView.translatesAutoresizingMaskIntoConstraints = false
        addCredentialFooterView.button.addTarget(self, action: #selector(addCredential), for: .touchUpInside)
        addCredentialFooterView.bankIdAnotherDeviceButton.addTarget(self, action: #selector(addBankIDCredentialOnAnotherDevice), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(addCredentialFooterView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addCredentialFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addCredentialFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addCredentialFooterView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigationItem.title = provider.displayName
        navigationItem.largeTitleDisplayMode = .never
        addCredentialFooterView.button.isEnabled = form.fields.isEmpty

        setupHelpFootnote()
        layoutHelpFootnote()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let headerHeight = headerView.systemLayoutSizeFitting(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(249)).height
        var frame = headerView.frame
        frame.size.height = headerHeight
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame = frame

        tableView.contentInset.bottom = addCredentialFooterView.frame.height
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
        helpLabel.textColor = Color.label

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

// MARK: - Keyboard Helper
extension AddCredentialViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            addCredentialFooterView.updateButtonBottomConstraint(keyboardHeight)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        addCredentialFooterView.resetButtonBottomConstraint()
    }
}

// MARK: - UITableViewDataSource

extension AddCredentialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldTableViewCell.reuseIdentifier, for: indexPath)
        let field = form.fields[indexPath.item]
        if let textFieldCell = cell as? FormFieldTableViewCell {
            textFieldCell.configure(with: field)
            textFieldCell.delegate = self
            textFieldCell.setError(with: errors[indexPath]?.localizedDescription)
        }
        return cell
    }
}

// MARK: - Actions

extension AddCredentialViewController {
    @objc private func addCredential() {
        view.endEditing(false)

        var indexPathsToUpdate = Set(errors.keys)
        errors = [:]

        do {
            try form.validateFields()
            task = credentialController.addCredential(
                provider,
                form: form,
                progressHandler: { [weak self] status in
                    DispatchQueue.main.async {
                        self?.handleAddCredentialStatus(status)
                    }
                },
                completion: { [weak self] result in
                    DispatchQueue.main.async {
                        self?.handleAddCredentialCompletion(result)
                    }
                }
            )
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

    @objc private func addBankIDCredentialOnAnotherDevice() {
        view.endEditing(false)

        var indexPathsToUpdate = Set(errors.keys)
        errors = [:]

        do {
            try form.validateFields()
            task = credentialController.addCredential(
                provider,
                form: form,
                progressHandler: { [weak self] status in
                    DispatchQueue.main.async {
                        self?.handleAddCredentialStatus(status, shouldAuthenticateInAnotherDevice: true)
                    }
                },
                completion: { [weak self] result in
                    DispatchQueue.main.async {
                        self?.handleAddCredentialCompletion(result)
                    }
                }
            )
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

    private func showMoreInfo() {
        addCredentialNavigator?.showScopeDescriptions()
    }

    private func showTermsAndConditions(_ url: URL) {
        addCredentialNavigator?.showWebContent(with: url)
    }

    private func showPrivacyPolicy(_ url: URL) {
        addCredentialNavigator?.showWebContent(with: url)
    }
}

// MARK: - Handlers

extension AddCredentialViewController {
    private func handleAddCredentialStatus(_ status: AddCredentialTask.Status, shouldAuthenticateInAnotherDevice: Bool = false) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            if shouldAuthenticateInAnotherDevice {
                thirdPartyAppAuthenticationTask.qr { [weak self] qrImage in
                    DispatchQueue.main.async {
                        self?.showQRCodeView(qrImage: qrImage)
                    }
                }
            } else {
                 thirdPartyAppAuthenticationTask.openThirdPartyApp()
            }
        case .updating(let status):
            showUpdating(status: status)
        }
    }

    private func handleAddCredentialCompletion(_ result: Result<Credential, Error>) {
        do {
            _ = try result.get()
            showCredentialUpdated()
        } catch {
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
        task = nil
    }
}

// MARK: - Navigation

extension AddCredentialViewController {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        hideUpdatingView()
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = TinkNavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showUpdating(status: String) {
        hideQRCodeView {
            if self.statusViewController == nil {
                let statusViewController = AddCredentialStatusViewController()
                statusViewController.modalTransitionStyle = .crossDissolve
                statusViewController.modalPresentationStyle = .custom
                statusViewController.transitioningDelegate = self.statusPresentationManager
                self.present(statusViewController, animated: true)
                self.statusViewController = statusViewController
            }
            self.statusViewController?.status = status
        }
    }

    private func hideUpdatingView(animated: Bool = false, completion: (() -> Void)? = nil) {
        hideQRCodeView(animated: animated)
        guard statusViewController != nil else {
            completion?()
            return
        }
        dismiss(animated: animated, completion: completion)
        statusViewController = nil
    }

    private func showQRCodeView(qrImage: UIImage) {
        hideUpdatingView {
            let qrImageViewController = QRImageViewController(qrImage: qrImage)
            self.qrImageViewController = qrImageViewController
            self.present(qrImageViewController, animated: true)
        }
    }

    private func hideQRCodeView(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard qrImageViewController != nil else {
            completion?()
            return
        }
        dismiss(animated: animated, completion: completion)
        qrImageViewController = nil
    }

    private func showCredentialUpdated() {
        hideUpdatingView(animated: true) {
            self.addCredentialNavigator?.showAddCredentialSuccess()
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
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: FormFieldTableViewCellDelegate {
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return true
        }

        let lastIndexItem = form.fields.count - 1
        if lastIndexItem == indexPath.item {
            addCredential()
        }

        let nextIndexPath = IndexPath(row: indexPath.item + 1, section: indexPath.section)
        _ = cell.resignFirstResponder()

        guard form.fields.count > nextIndexPath.item,
            form.fields[indexPath.item + 1].attributes.isEditable,
            let nextCell = tableView.cellForRow(at: nextIndexPath)
            else { return true }

        nextCell.becomeFirstResponder()

        return false
    }

    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.item].text = text
        errors[indexPath] = nil
        tableView.beginUpdates()
        cell.setError(with: nil)
        tableView.endUpdates()
        addCredentialFooterView.button.isEnabled = form.areFieldsValid
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

// MARK: - AddCredentialHeaderViewDelegate

extension AddCredentialViewController: AddCredentialHeaderViewDelegate {
    func addCredentialHeaderViewDidTapReadMore(_ addCredentialHeaderView: AddCredentialHeaderView) {
        showMoreInfo()
    }
}

// MARK: - AddCredentialFooterViewDelegate

extension AddCredentialViewController: AddCredentialFooterViewDelegate {
    func addCredentialFooterViewDidTapLink(_ addCredentialFooterView: AddCredentialFooterView, url: URL) {
        showPrivacyPolicy(url)
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
