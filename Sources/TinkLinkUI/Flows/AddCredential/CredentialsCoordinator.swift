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

    private lazy var authorizationController = AuthorizationController(tink: tink)
    private lazy var credentialsController = CredentialsController(tink: tink)
    private lazy var providerController = ProviderController(tink: tink)

    private lazy var addCredentialsSession = AddCredentialsSession(providerController: self.providerController, credentialsController: self.credentialsController, authorizationController: self.authorizationController, parentViewController: self.parentViewController)

    private let action: Action
    private let completion: (Result<(Credentials, AuthorizationCode?), Error>) -> Void
    private let parentViewController: UIViewController
    private let tink: Tink
    private let clientDescription: ClientDescription

    private let containerViewController = ContainerViewController()

    private var result: Result<(Credentials, AuthorizationCode?), Error>?

    init(tink: Tink = .shared, parentViewController: UIViewController, clientDescription: ClientDescription, action: Action, completion: @escaping (Result<(Credentials, AuthorizationCode?), Error>) -> Void) {
        self.action = action
        self.completion = completion
        self.tink = tink
        self.parentViewController = parentViewController
        self.clientDescription = clientDescription
    }

    func start() {
        let viewController: UIViewController
        switch action {
        case .add(provider: let provider, _):
            let credentialsViewController = CredentialsFormViewController(provider: provider, credentialsController: credentialsController, clientName: clientDescription.name, isAggregator: clientDescription.isAggregator, isVerified: clientDescription.isVerified)
            credentialsViewController.delegate = self
            // TODO: Figure out how to send prefill strategy
//            credentialsViewController.prefillStrategy = prefill

            viewController = credentialsViewController

        case .authenticate(credentialsID: let id):
            fetchCredentials(with: id) { credentials in
                self.addCredentialsSession.authenticateCredentials(credentials: credentials) { result in
                    self.completion(result.map { ($0, nil) } )
                }
            }
            viewController = LoadingViewController()

        case .refresh(credentialsID: let id):
            fetchCredentials(with: id) { credentials in
                self.addCredentialsSession.refreshCredentials(credentials: credentials) { result in
                    self.completion(result.map { ($0, nil) } )
                }
            }
            viewController = LoadingViewController()

        case .update(credentialsID: let id):
            fetchCredentials(with: id) { credentials in
                // Show form 
            }
            viewController = LoadingViewController()
        }

        containerViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        containerViewController.setViewController(viewController)
        parentViewController.show(containerViewController, sender: self)
    }

    private func fetchCredentials(with id: Credentials.ID, then: @escaping (Credentials) -> Void) {
        credentialsController.credentials(id: id) { (result) in
            do {
                let credentials = try result.get()
                then(credentials)
            } catch {
                self.completion(.failure(error))
            }
        }
    }
}

extension CredentialsCoordinator: AddCredentialsViewControllerDelegate {

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

    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        containerViewController.dismiss(animated: true)
    }

    @objc private func cancel() {
        completion(.failure(TinkLinkError.userCancelled))
    }

    func addCredential(provider: Provider, form: Form) {
        guard case .add(provider: _, mode: let mode) = action else { return }

        addCredentialsSession.addCredential(provider: provider, form: form, mode: mode) { [weak self] result in
            do {
                let _ = try result.get()
                self?.result = result
                self?.showAddCredentialSuccess()
            } catch let error as ThirdPartyAppAuthenticationTask.Error {
                self?.showDownloadPrompt(for: error)
            } catch ServiceError.cancelled {
                // No-op
            } catch {
                self?.showAlert(for: error)
            }
        }
    }

    func showAddCredentialSuccess() {
        let viewController = CredentialsSuccessfullyAddedViewController(companyName: clientDescription.name) { [weak self] in
            guard let self = self, let result = self.result else { return }
            self.completion(result)
        }
        parentViewController.show(viewController, sender: self)
    }

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

        parentViewController.present(alertController, animated: true)
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

        parentViewController.present(alertController, animated: true)
    }
}
