import UIKit
import TinkLink

final class RefreshCredentialsViewController: UITableViewController {
    private let credentialsContext = CredentialsContext()
    private let transferContext = TransferContext()
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
        case transfer
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
        let sections: [Section] = [.status, .actions(actions), .delete, .transfer]
        return sections
    }

    private let dateFormatter = DateFormatter()

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

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension RefreshCredentialsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Status")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "Button")
    }
}

// MARK: - UITableViewDataSource

extension RefreshCredentialsViewController {
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
        case .status, .delete, .transfer:
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
        case .transfer:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Transfer"
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension RefreshCredentialsViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch sections[indexPath.section] {
        case .status:
            return false
        case .actions:
            return refreshCredentialsTask == nil
        case .delete:
            return !isDeleting
        case .transfer:
            return true
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
            credentialsContext.delete(credentials) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isDeleting = false
                    do {
                        _ = try result.get()
                        self?.navigationController?.popViewController(animated: true)
                    } catch {
                        // Handle any errors
                    }
                }
            }
        case .transfer:
            // TODO:
            break
        }
    }
}

// MARK: - Actions

extension RefreshCredentialsViewController {
    private func refresh() {
        refreshCredentialsTask = credentialsContext.refresh(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
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
                dismiss(animated: true)
            }
            self.credentials = refreshedCredentials
        case .updating:
            if isPresentingQR {
                dismiss(animated: true)
            }
            self.credentials = refreshedCredentials
        case .awaitingSupplementalInformation(let task):
            showSupplementalInformation(for: task)
        case .awaitingThirdPartyAppAuthentication(let task):
            self.credentials = refreshedCredentials
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
            self.credentials = try result.get()
        } catch {
            showAlert(for: error)
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

    private func showAlert(for error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension RefreshCredentialsViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credentials) {
        self.credentials = credential
        dismiss(animated: true)
    }

    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }
}
