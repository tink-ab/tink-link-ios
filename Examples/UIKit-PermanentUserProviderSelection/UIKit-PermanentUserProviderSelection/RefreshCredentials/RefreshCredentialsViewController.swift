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
        case delete
    }

    private var sections = Section.allCases

    private let dateFormatter = DateFormatter()

    private var refreshCredentialsTask: RefreshCredentialTask? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    private var isDeleting = false

    init(credentials: Credentials) {
        self.credentials = credentials

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

        tableView.register(CredentialsStatusTableViewCell.self, forCellReuseIdentifier: "Status")
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
        return 1
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
        case .delete:
            isDeleting = true
            credentialsContext.delete(credentials) { [weak self] result in
                DispatchQueue.main.async {
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

    private func handleProgress(_ status: RefreshCredentialTask.Status) {
        switch status {
        case .created(credentials: let credentials):
            self.credentials = credentials
        case .authenticating(credentials: let credentials):
            self.credentials = credentials
        case .updating(credentials: let credentials, status: let status):
            self.credentials = credentials
        case .awaitingSupplementalInformation(task: let task):
            showSupplementalInformation(for: task)
        case .awaitingThirdPartyAppAuthentication(credentials: let credentials, task: let task):
            self.credentials = credentials
            task.handle { [weak self] taskStatus in
                DispatchQueue.main.async {
                    switch taskStatus {
                    case .awaitAuthenticationOnAnotherDevice:
                        let alertController = UIAlertController(title: "Awaiting Authentication on Another Device ", message: nil, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alertController.addAction(action)
                        self?.present(alertController, animated: true)
                    case .qrImage(let image):
                        let qrViewController = QRViewController(image: image)
                        self?.present(qrViewController, animated: true)
                    }
                }
            }
        case .sessionExpired(credentials: let credentials):
            self.credentials = credentials
        case .updated(credentials: let credentials):
            self.credentials = credentials
        case .error(credentials: let credentials, error: let error):
            self.credentials = credentials
        }
    }

    private func handleCompletion(_ result: Result<Credentials, Error>) {
        do {
            self.credentials = try result.get()
        } catch {
            // Handle any errors
        }
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
