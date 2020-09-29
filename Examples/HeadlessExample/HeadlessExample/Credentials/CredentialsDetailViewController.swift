import UIKit
import TinkLink

/// A view controller that presents credentials details.
final class CredentialsDetailViewController: UITableViewController {
    private let credentialsContext = Tink.shared.credentialsContext
    private var credentials: Credentials {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    private enum Section {
        case status
        case actions([Action])
        case delete
    }

    private enum Action {
        case refresh
        case update
        case authenticate
    }

    private var sections: [Section] {
        var actions: [Action] = [.refresh, .update]
        if canAuthenticate {
            actions.append(.authenticate)
        }
        let sections: [Section] = [.status, .actions(actions), .delete]
        return sections
    }

    private let dateFormatter = DateFormatter()

    private var statusViewController: StatusViewController?

    private var refreshCredentialsTask: RefreshCredentialsTask? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    private var isDeleting = false

    private var provider: Provider

    private var canAuthenticate: Bool {
        provider.accessType == .openBanking
    }

    init(credentials: Credentials, provider: Provider) {
        self.credentials = credentials
        self.provider = provider

        super.init(style: .grouped)

        navigationItem.largeTitleDisplayMode = .never

        hidesBottomBarWhenPushed = true

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension CredentialsDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Status")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "Button")
    }
}

// MARK: - UITableViewDataSource

extension CredentialsDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch sections[section] {
        case .status:
            return credentials.statusPayload
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .status, .delete:
            return 1
        case .actions(let actionItems):
            return actionItems.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .status:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Status", for: indexPath)
            cell.textLabel?.text = String(describing: credentials.status).localizedCapitalized
            cell.detailTextLabel?.text = credentials.statusUpdated.map(dateFormatter.string(from:))
            return cell
        case .actions(let actionItems):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.tintColor = nil
            switch actionItems[indexPath.item] {
            case .refresh:
                cell.actionLabel.text = "Refresh"
            case .update:
                cell.actionLabel.text = "Update"
            case .authenticate:
                cell.actionLabel.text = "Authenticate"
            }

            return cell
        case .delete:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Delete"
            cell.tintColor = .systemRed
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension CredentialsDetailViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch sections[indexPath.section] {
        case .status:
            return false
        case .actions:
            return refreshCredentialsTask == nil
        case .delete:
            return !isDeleting
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .status:
            break
        case .actions(let actionItems):
            switch actionItems[indexPath.item] {
            case .refresh:
                refresh()
            case .update:
                update()
            case .authenticate:
                authenticate()
            }
            tableView.deselectRow(at: indexPath, animated: true)
        case .delete:
            isDeleting = true
            showStatus("Deleting…", animated: true)
            credentialsContext.delete(credentials) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isDeleting = false
                    do {
                        _ = try result.get()
                        self?.hideStatus(animated: true) {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } catch {
                        self?.showAlert(for: error)
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension CredentialsDetailViewController {
    private func refresh() {
        refreshCredentialsTask = credentialsContext.refresh(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            authenticationHandler: { [weak self] authentication in
                DispatchQueue.main.async {
                    self?.handleAuthentication(authentication)
                }
            },
            progressHandler: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleProgress(status)
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleCompletion(result)
                }
            }
        )
    }

    private func update() {
        let updateCredentialsViewController = UpdateCredentialsViewController(provider: provider, credentials: credentials) { [weak self] result in
            do {
                self?.credentials = try result.get()
            } catch {
                // Handle any errors
            }
            self?.dismiss(animated: true)
        }
        updateCredentialsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancelUpdateCredentials))
        let viewController = UINavigationController(rootViewController: updateCredentialsViewController)
        present(viewController, animated: true)
    }

    @objc private func cancelUpdateCredentials(_ sender: Any) {
        dismiss(animated: true)
    }

    private func authenticate() {
        refreshCredentialsTask = credentialsContext.authenticate(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            authenticationHandler: { [weak self] authentication in
                DispatchQueue.main.async {
                    self?.handleAuthentication(authentication)
                }
            },
            progressHandler: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleProgress(status)
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleCompletion(result)
                }
            }
        )
    }

    private var isPresentingQR: Bool {
        guard let navigationController = presentedViewController as? UINavigationController else { return false }
        return navigationController.topViewController is QRViewController
    }

    private func handleProgress(_ status: RefreshCredentialsTask.Status) {
        guard let refreshedCredentials = refreshCredentialsTask?.credentials else { return }
        switch status {
        case .authenticating:
            if isPresentingQR {
                dismiss(animated: true) {
                    self.showStatus("Authenticating…", animated: true)
                }
            } else {
                showStatus("Authenticating…", animated: true)
            }
            credentials = refreshedCredentials
        case .updating(let status):
            if isPresentingQR {
                dismiss(animated: true) {
                    self.showStatus(status, animated: true)
                }
            } else {
                showStatus(status, animated: true)
            }
            credentials = refreshedCredentials
        }
    }

    private func handleAuthentication(_ authentication: AuthenticationTask) {
        guard let refreshedCredentials = refreshCredentialsTask?.credentials else { return }
        switch authentication {
        case .awaitingSupplementalInformation(let task):
            hideStatus(animated: true) {
                self.showSupplementalInformation(for: task)
            }
        case .awaitingThirdPartyAppAuthentication(let task):
            credentials = refreshedCredentials
            task.handle { [weak self] taskStatus in
                DispatchQueue.main.async {
                    self?.handleThirdPartyAppAuthentication(taskStatus)
                }
            }
        }
    }

    private func handleThirdPartyAppAuthentication(_ taskStatus: ThirdPartyAppAuthenticationTask.Status) {
        switch taskStatus {
        case .awaitAuthenticationOnAnotherDevice:
            let alertController = UIAlertController(title: "Awaiting Authentication on Another Device ", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        case .qrImage(let image):
            let qrViewController = QRViewController(image: image)
            qrViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancelQRCode))
            let navigationController = UINavigationController(rootViewController: qrViewController)
            present(navigationController, animated: true)
        }
    }

    private func handleCompletion(_ result: Result<Credentials, Error>) {
        do {
            credentials = try result.get()
            hideStatus(animated: true)
        } catch {
            hideStatus(animated: true) {
                self.showAlert(for: error)
            }
        }
        refreshCredentialsTask = nil
    }

    @objc private func cancelQRCode(_ sender: Any) {
        refreshCredentialsTask?.cancel()
        dismiss(animated: true)
    }

    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showStatus(_ status: String, animated: Bool) {
        if statusViewController == nil {
            let statusViewController = StatusViewController()
            statusViewController.modalTransitionStyle = .crossDissolve
            statusViewController.modalPresentationStyle = .overFullScreen
            present(statusViewController, animated: animated)
            UIView.animate(withDuration: 0.3) {
                self.view.tintAdjustmentMode = .dimmed
            }
            self.statusViewController = statusViewController
        }
        statusViewController?.status = status
    }

    private func hideStatus(animated: Bool, completion: (() -> Void)? = nil) {
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
}

// MARK: - SupplementalInformationViewControllerDelegate

extension CredentialsDetailViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credentials) {
        credentials = credential
        dismiss(animated: true)
    }

    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }
}
