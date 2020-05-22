import UIKit
import TinkLink

final class CredentialsCoordinator {

    enum AddCredentialsMode {
        case anonymous(scopes: [Scope])
        case user
    }

    enum Action {
        case add(provider: Provider, mode: AddCredentialsMode)
        case update(credentialsID: Credentials.ID)
        case refresh(credentialsID: Credentials.ID)
        case authenticate(credentialsID: Credentials.ID)
    }

    var prefillStrategy: TinkLinkViewController.PrefillStrategy = .none

    private let authorizationController: AuthorizationController
    private let credentialsController: CredentialsController
    private let providerController: ProviderController

    private lazy var addCredentialsSession = AddCredentialsSession(providerController: self.providerController, credentialsController: self.credentialsController, authorizationController: self.authorizationController, parentViewController: self.parentViewController)

    private let action: Action
    private let completion: (Result<(Credentials, AuthorizationCode?), TinkLinkError>) -> Void
    private weak var parentViewController: UIViewController?
    private let clientDescription: ClientDescription

    private let containerViewController = ContainerViewController()

    private var result: Result<(Credentials, AuthorizationCode?), TinkLinkError>?
    private var fetchedCredentials: Credentials?

    init(authorizationController: AuthorizationController, credentialsController: CredentialsController, providerController: ProviderController, parentViewController: UIViewController, clientDescription: ClientDescription, action: Action, completion: @escaping (Result<(Credentials, AuthorizationCode?), TinkLinkError>) -> Void) {
        self.authorizationController = authorizationController
        self.credentialsController = credentialsController
        self.providerController = providerController
        self.action = action
        self.completion = completion
        self.parentViewController = parentViewController
        self.clientDescription = clientDescription
    }

    func start() {

        var viewController: UIViewController? = nil
        switch action {
        case .add(provider: let provider, _):
            let credentialsViewController = CredentialsFormViewController(provider: provider, credentialsController: credentialsController, clientName: clientDescription.name, isAggregator: clientDescription.isAggregator, isVerified: clientDescription.isVerified)
            credentialsViewController.delegate = self
            credentialsViewController.prefillStrategy = prefillStrategy

            viewController = credentialsViewController

        case .authenticate(credentialsID: let id):
            fetchCredentials(with: id) { credentials in
                self.fetchedCredentials = credentials
                self.addCredentialsSession.authenticateCredentials(credentials: credentials) { result in
                    self.handleCompletion(for: result.map { ($0, nil) } )
                }
            }

        case .refresh(credentialsID: let id):
            fetchCredentials(with: id) { credentials in
                self.fetchedCredentials = credentials
                self.addCredentialsSession.refreshCredentials(credentials: credentials) { result in
                    self.handleCompletion(for: result.map { ($0, nil) } )
                }
            }

        case .update(credentialsID: let id):
            fetchCredentials(with: id) { credentials in
                self.fetchedCredentials = credentials
                self.fetchProvider(with: credentials.providerID) { provider in
                    let credentialsViewController = CredentialsFormViewController(credentials: credentials, provider: provider, credentialsController: self.credentialsController, clientName: self.clientDescription.name, isAggregator: self.clientDescription.isAggregator, isVerified: self.clientDescription.isVerified)
                    credentialsViewController.delegate = self
                    credentialsViewController.prefillStrategy = self.prefillStrategy
                    self.containerViewController.setViewController(credentialsViewController)
                }
            }
            viewController = LoadingViewController()
        }

        if let viewController = viewController {
            containerViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            containerViewController.setViewController(viewController)
            parentViewController?.show(containerViewController, sender: self)
        }
    }

    private func handleCompletion(for result: Result<(Credentials, AuthorizationCode?), Error>) {
        do {
            let values = try result.get()
            self.result = .success(values)
            showAddCredentialSuccess()
        } catch let error as ThirdPartyAppAuthenticationTask.Error {
            showDownloadPrompt(for: error)
        } catch ServiceError.cancelled {
            // No-op
        } catch {
            showAlert(for: error)
        }
    }

    func showAddCredentialSuccess() {
        DispatchQueue.main.async {
            let viewController = CredentialsSuccessfullyAddedViewController(companyName: self.clientDescription.name) { [weak self] in
                guard let self = self, let result = self.result else { return }
                self.completion(result)
            }
            self.parentViewController?.show(viewController, sender: self)
        }
    }
}

// MARK: - Fetcher Helpers
extension CredentialsCoordinator {

    private func fetchCredentials(with id: Credentials.ID, then: @escaping (Credentials) -> Void) {
        credentialsController.credentials(id: id) { (result) in
            do {
                let credentials = try result.get()
                then(credentials)
            } catch {
                // TODO: This error should be improved
                self.completion(.failure(.credentialsNotFound))
            }
        }
    }

    private func fetchProvider(with id: Provider.ID, then: @escaping (Provider) -> Void) {
        providerController.fetchProvider(with: id) { result in
            do {
                let provider = try result.get()
                then(provider)
            } catch {
                // TODO: This error should be improved
                self.completion(.failure(.providerNotFound))
            }
        }
    }
}

extension CredentialsCoordinator: CredentialsFormViewControllerDelegate {

    func showScopeDescriptions() {
        let scopeList: [Scope]
        if case .add(provider: _, mode: let mode) = action, case let .anonymous(scopes) = mode {
            scopeList = scopes
        } else {
            scopeList = []
        }
        let viewController = ScopeDescriptionListViewController(authorizationController: authorizationController, scopes: scopeList)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMoreInfo))
        let navigationController = TinkNavigationController(rootViewController: viewController)
        containerViewController.present(navigationController, animated: true)
    }

    func showWebContent(with url: URL) {
        let viewController = LegalViewController(url: url)
        containerViewController.present(viewController, animated: true)
    }


    func submit(form: Form) {

        switch action {

        case .add(provider: let provider, mode: let mode):
            addCredentialsSession.addCredential(provider: provider, form: form, mode: mode) { [weak self] result in
                self?.handleCompletion(for: result)
            }

        case .update(credentialsID: let id):
            guard let fetchedCredentials = fetchedCredentials else {
                fatalError()
            }
            assert(id == fetchedCredentials.id)

            addCredentialsSession.updateCredentials(credentials: fetchedCredentials, form: form) { [weak self] result in
                self?.handleCompletion(for: result.map { ($0, nil) })
            }

        case .authenticate, .refresh:
            break
        }
    }
}

// MARK: - Actions
extension CredentialsCoordinator {

    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        containerViewController.dismiss(animated: true)
    }

    @objc private func cancel() {
        completion(.failure(TinkLinkError.userCancelled))
    }
}

// MARK: - Alerts
extension CredentialsCoordinator {

    private func showDownloadPrompt(for thirdPartyAppAuthenticationError: ThirdPartyAppAuthenticationTask.Error) {
        let alertController = UIAlertController(title: thirdPartyAppAuthenticationError.errorDescription, message: thirdPartyAppAuthenticationError.failureReason, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthenticationError.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
            let cancelAction = UIAlertAction(title: Strings.ThirdPartyAppAuthentication.DownloadAlert.cancel, style: .cancel)
            let downloadAction = UIAlertAction(title: Strings.ThirdPartyAppAuthentication.DownloadAlert.download, style: .default, handler: { _ in
                UIApplication.shared.open(appStoreURL)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: Strings.ThirdPartyAppAuthentication.DownloadAlert.dismiss, style: .default)
            alertController.addAction(okAction)
        }

        parentViewController?.present(alertController, animated: true)
    }

    private func showAlert(for error: Error) {
        let title: String?
        let message: String?
        if let error = error as? LocalizedError {
            title = error.errorDescription
            message = error.failureReason
        } else {
            title = Strings.Generic.Alert.title
            message = error.localizedDescription
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: Strings.Generic.Alert.ok, style: .default)
        alertController.addAction(okAction)

        parentViewController?.present(alertController, animated: true)
    }
}
