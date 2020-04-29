import UIKit
import TinkLink

final class RefreshCredentialsViewController: UITableViewController {
    private let credentialsContext = CredentialsContext()
    private var credentials: Credentials {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    private enum Section: CaseIterable {
        case status
        case refresh
        case update
        case authenticate
        case delete
    }

    private var sections = Section.allCases

    private let dateFormatter = DateFormatter()

    private var refreshCredentialsTask: RefreshCredentialsTask? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    private var isDeleting = false

    private var providersByID: [Provider.ID: Provider]

    private var canAuthenticate: Bool {
        providersByID[credentials.providerID]?.accessType == .openBanking
    }

    init(credentials: Credentials, providersByID: [Provider.ID: Provider]) {
        self.credentials = credentials
        self.providersByID = providersByID

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
        case .status, .refresh, .update, .delete:
            return 1
        case .authenticate:
            return canAuthenticate ? 1 : 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .status:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Status", for: indexPath)
            cell.textLabel?.text = String(describing: credentials.status).localizedCapitalized
            cell.detailTextLabel?.text = credentials.statusUpdated.map(dateFormatter.string(from:))
            return cell
        case .refresh:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Refresh"
            cell.tintColor = nil
            return cell
        case .update:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Update"
            cell.tintColor = nil
            return cell
        case .authenticate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath) as! ButtonTableViewCell
            cell.actionLabel.text = "Authenticate"
            cell.tintColor = nil
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

extension RefreshCredentialsViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch sections[indexPath.section] {
        case .status:
            return false
        case .refresh:
            return refreshCredentialsTask == nil
        case .update:
            return refreshCredentialsTask == nil
        case .authenticate:
            return refreshCredentialsTask == nil
        case .delete:
            return !isDeleting
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .status:
            break
        case .refresh:
            refresh()
            tableView.deselectRow(at: indexPath, animated: true)
        case .update:
            update()
        case .authenticate:
            authenticate()
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
        case .created:
            self.credentials = refreshedCredentials
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
        case .sessionExpired:
            self.credentials = refreshedCredentials
        case .updated:
            self.credentials = refreshedCredentials
        case .error:
            self.credentials = refreshedCredentials
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
            qrViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancelRefreshingCredentials(_:)))
            let navigationController = UINavigationController(rootViewController: qrViewController)
            present(navigationController, animated: true)
        }
    }
    private func handleCompletion(_ result: Result<Credentials, Error>) {
        do {
            self.credentials = try result.get()
        } catch {
            // Handle any errors
        }
    }

    @objc private func cancelRefreshingCredentials(_ sender: Any) {
        refreshCredentialsTask?.cancel()
        dismiss(animated: true)
    }

    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
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
