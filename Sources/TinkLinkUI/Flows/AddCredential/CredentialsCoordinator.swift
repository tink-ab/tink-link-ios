import UIKit
import TinkLink

protocol CredentialsCoordinatorPresenting: AnyObject {
    func showLoadingIndicator(text: String?, onCancel: (() -> Void)?)
    func show(_ viewController: UIViewController)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func forcePresent(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

protocol CredentialsCoordinatorDelegate: AnyObject {
    func didFinishCredentialsForm()
}

final class CredentialsCoordinator {
    enum AddCredentialsMode {
        case anonymous(scopes: [Scope])
        case user(refreshableItems: RefreshableItems)
    }

    enum Action {
        case create(provider: Provider, mode: AddCredentialsMode)
        case update(credentialsID: Credentials.ID)
        case refresh(credentialsID: Credentials.ID, forceAuthenticate: Bool, refreshableItems: RefreshableItems)
        case authenticate(credentialsID: Credentials.ID)
    }

    var prefillStrategy: TinkLinkViewController.PrefillStrategy = .none

    private let authorizationController: AuthorizationController
    private let credentialsController: CredentialsController
    private let providerController: ProviderController
    private let market: Market?

    private weak var credentialsViewController: CredentialsFormViewController?

    private lazy var addCredentialsSession = AddCredentialsSession(providerController: self.providerController, credentialsController: self.credentialsController, authorizationController: self.authorizationController, tinkLinkTracker: tinkLinkTracker, presenter: self.presenter)

    private let action: Action
    private let completion: (Result<(Credentials, AuthorizationCode?), TinkLinkUIError>) -> Void
    private weak var presenter: CredentialsCoordinatorPresenting?
    private weak var delegate: CredentialsCoordinatorDelegate?
    private let clientDescription: ClientDescription
    private let tinkLinkTracker: TinkLinkTracker

    private var fetchedCredentials: Credentials?

    private var callCompletionOnError: Bool {
        switch action {
        case .authenticate, .refresh:
            return true
        case .update, .create:
            return false
        }
    }

    init(market: Market?, authorizationController: AuthorizationController, credentialsController: CredentialsController, providerController: ProviderController, presenter: CredentialsCoordinatorPresenting, delegate: CredentialsCoordinatorDelegate, clientDescription: ClientDescription, action: Action, tinkLinkTracker: TinkLinkTracker, completion: @escaping (Result<(Credentials, AuthorizationCode?), TinkLinkUIError>) -> Void) {
        self.market = market
        self.authorizationController = authorizationController
        self.credentialsController = credentialsController
        self.providerController = providerController
        self.action = action
        self.completion = completion
        self.presenter = presenter
        self.delegate = delegate
        self.clientDescription = clientDescription
        self.tinkLinkTracker = tinkLinkTracker
    }

    func start() {
        switch action {
        case .create(provider: let provider, _):
            let credentialsViewController = CredentialsFormViewController(provider: provider, credentialsController: credentialsController, authorizationController: authorizationController, clientName: clientDescription.name, isAggregator: clientDescription.isAggregator, isVerified: clientDescription.isVerified, tinkLinkTracker: tinkLinkTracker)
            credentialsViewController.delegate = self
            credentialsViewController.prefillStrategy = prefillStrategy
            credentialsViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            self.credentialsViewController = credentialsViewController
            presenter?.show(credentialsViewController)
            tinkLinkTracker.providerID = provider.id.value
            tinkLinkTracker.track(screen: .submitCredentials)

        case .authenticate(credentialsID: let id):
            tinkLinkTracker.credentialsID = id.value
            fetchCredentials(with: id) { [weak self] credentials in
                guard let self = self else { return }
                self.fetchedCredentials = credentials
                self.tinkLinkTracker.providerID = credentials.providerName.value
                self.tinkLinkTracker.track(applicationEvent: .initializedWithoutProvider)
                self.tinkLinkTracker.track(applicationEvent: .providerAuthenticationInitialized)
                self.addCredentialsSession.authenticateCredentials(credentials: credentials) { [weak self] result in
                    self?.handleCompletion(for: result.map { ($0, nil) })
                }
            }
            presenter?.showLoadingIndicator(text: nil, onCancel: nil)

        case .refresh(credentialsID: let id, let forceAuthenticate, let refreshableItems):
            tinkLinkTracker.credentialsID = id.value
            fetchCredentials(with: id) { [weak self] credentials in
                guard let self = self else { return }
                self.fetchedCredentials = credentials
                self.tinkLinkTracker.providerID = credentials.providerName.value
                self.tinkLinkTracker.track(applicationEvent: .initializedWithoutProvider)
                self.fetchProviderIgnoringErrors(with: credentials.providerName, for: self.market) { [weak self] provider in
                    guard let self = self else { return }
                    switch provider.accessType {
                    case .openBanking:
                        self.tinkLinkTracker.track(applicationEvent: .providerAuthenticationInitialized)
                    case .other:
                        self.tinkLinkTracker.track(applicationEvent: .credentialsSubmitted)
                    default: break
                    }
                }
                self.addCredentialsSession.refreshCredentials(credentials: credentials, forceAuthenticate: forceAuthenticate, refreshableItems: refreshableItems) { [weak self] result in
                    self?.handleCompletion(for: result.map { ($0, nil) })
                }
            }
            presenter?.showLoadingIndicator(text: nil, onCancel: nil)

        case .update(credentialsID: let id):
            tinkLinkTracker.credentialsID = id.value
            fetchCredentials(with: id) { [weak self] credentials in
                guard let self = self else { return }
                self.fetchedCredentials = credentials
                self.fetchProvider(with: credentials.providerName, for: self.market) { [weak self] provider in
                    guard let self = self else { return }
                    let credentialsViewController = CredentialsFormViewController(credentials: credentials, provider: provider, credentialsController: self.credentialsController, authorizationController: self.authorizationController, clientName: self.clientDescription.name, isAggregator: self.clientDescription.isAggregator, isVerified: self.clientDescription.isVerified, tinkLinkTracker: self.tinkLinkTracker)
                    credentialsViewController.delegate = self
                    credentialsViewController.prefillStrategy = self.prefillStrategy
                    credentialsViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
                    self.credentialsViewController = credentialsViewController
                    self.presenter?.show(credentialsViewController)
                    self.tinkLinkTracker.providerID = credentials.providerName.value
                    self.tinkLinkTracker.track(applicationEvent: .initializedWithoutProvider)
                    self.tinkLinkTracker.track(screen: .submitCredentials)
                }
            }
            presenter?.showLoadingIndicator(text: nil, onCancel: nil)
        }
    }

    private func handleCompletion(for result: Result<(Credentials, AuthorizationCode?), Error>) {
        do {
            let (credentials, authorizationCode) = try result.get()
            tinkLinkTracker.credentialsID = credentials.id.value
            delegate?.didFinishCredentialsForm()
            showAddCredentialSuccess(with: credentials, authorizationCode: authorizationCode, for: action)
        } catch let error as TinkLinkError where error.code == .thirdPartyAppAuthenticationFailed {
            tinkLinkTracker.credentialsID = nil
            if let reason = error.thirdPartyAppAuthenticationFailureReason {
                showDownloadPrompt(for: reason)
            } else {
                showAlert(for: error)
            }
            tinkLinkTracker.track(screen: .error)
        } catch TinkLinkError.cancelled {
            tinkLinkTracker.credentialsID = nil
            if callCompletionOnError {
                completion(.failure(.init(code: .userCancelled)))
            } else if let credentialsViewController = credentialsViewController {
                presenter?.show(credentialsViewController)
            }
        } catch TinkLinkUIError.userCancelled {
            tinkLinkTracker.credentialsID = nil
            if callCompletionOnError {
                completion(.failure(.init(code: .userCancelled)))
            } else if let credentialsViewController = credentialsViewController {
                presenter?.show(credentialsViewController)
            }
        } catch {
            showAlert(for: error) { [weak self] in
                if let credentialsViewController = self?.credentialsViewController {
                    self?.presenter?.show(credentialsViewController)
                }
            }
            tinkLinkTracker.credentialsID = nil
            tinkLinkTracker.track(screen: .error)
        }
    }

    func showAddCredentialSuccess(with credentials: Credentials, authorizationCode: AuthorizationCode?, for: Action) {
        DispatchQueue.main.async {
            switch self.action {
            case .create(provider: let provider, _):
                let viewController = CredentialsSuccessfullyAddedViewController(companyName: provider.displayName, operation: .create, tinkLinkTracker: self.tinkLinkTracker) { [weak self] in
                    self?.completion(.success((credentials, authorizationCode)))
                }
                self.tinkLinkTracker.track(screen: .success)
                self.presenter?.show(viewController)
            default:
                self.fetchProvider(with: credentials.providerName, for: self.market) { [weak self] provider in
                    guard let self = self else { return }
                    let viewController = CredentialsSuccessfullyAddedViewController(companyName: provider.displayName, operation: .other, tinkLinkTracker: self.tinkLinkTracker) { [weak self] in
                        self?.completion(.success((credentials, authorizationCode)))
                    }
                    self.tinkLinkTracker.track(screen: .success)
                    self.presenter?.show(viewController)
                }
            }
        }
    }
}

// MARK: - Fetcher Helpers

extension CredentialsCoordinator {
    private func fetchCredentials(with id: Credentials.ID, then: @escaping (Credentials) -> Void) {
        credentialsController.credentials(id: id) { [weak self] result in
            do {
                let credentials = try result.get()
                then(credentials)
            } catch let tinkLinkError as TinkLinkError where tinkLinkError.code == .notFound {
                self?.completion(.failure(.init(code: .credentialsNotFound)))
            } catch {
                let uiError = TinkLinkUIError(error: error) ?? TinkLinkUIError(code: .internalError)
                self?.completion(.failure(uiError))
            }
        }
    }

    private func fetchProvider(with name: Provider.Name, for market: Market?, then: @escaping (Provider) -> Void) {
        providerController.fetchProvider(with: name, for: market) { [weak self] result in
            do {
                let provider = try result.get()
                then(provider)
            } catch let tinkLinkError as TinkLinkError where tinkLinkError.code == .notFound {
                self?.completion(.failure(.init(code: .providerNotFound)))
            } catch {
                let uiError = TinkLinkUIError(error: error) ?? TinkLinkUIError(code: .internalError)
                self?.completion(.failure(uiError))
            }
        }
    }

    // Fetch provider but ignore the error
    private func fetchProviderIgnoringErrors(with name: Provider.Name, for market: Market?, then: @escaping (Provider) -> Void) {
        if let provider = providerController.provider(providerName: name) {
            then(provider)
        } else {
            providerController.fetchProvider(with: name, for: market) { result in
                if let provider = try? result.get() {
                    then(provider)
                }
            }
        }
    }
}

extension CredentialsCoordinator: CredentialsFormViewControllerDelegate {
    func showScopeDescriptions() {
        let scopeList: [Scope]
        if case .create(provider: _, mode: let mode) = action, case .anonymous(let scopes) = mode {
            scopeList = scopes
        } else {
            // TODO: Get scopes based on provider and refreshable items.
            scopeList = []
        }
        let viewController = ScopeDescriptionListViewController(authorizationController: authorizationController, scopes: scopeList)
        viewController.delegate = self
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.Generic.close, style: .plain, target: self, action: #selector(closeMoreInfo))
        let navigationController = TinkNavigationController(rootViewController: viewController)
        presenter?.present(navigationController, animated: true, completion: nil)
    }

    func showWebContent(with url: URL) {
        let viewController = LegalViewController(url: url)
        let navigationController = TinkNavigationController(rootViewController: viewController)
        presenter?.present(navigationController, animated: true, completion: nil)
    }

    func submit(form: Form) {
        switch action {
        case .create(provider: let provider, mode: let mode):
            switch provider.accessType {
            case .openBanking:
                tinkLinkTracker.track(applicationEvent: .providerAuthenticationInitialized)
            case .other:
                tinkLinkTracker.track(applicationEvent: .credentialsSubmitted)
            default: break
            }
            addCredentialsSession.addCredential(provider: provider, form: form, mode: mode) { [weak self] result in
                self?.handleCompletion(for: result)
            }

        case .update(credentialsID: let id):
            guard let fetchedCredentials = fetchedCredentials else {
                fatalError()
            }
            assert(id == fetchedCredentials.id)

            fetchProviderIgnoringErrors(with: fetchedCredentials.providerName, for: market) { [weak self] provider in
                switch provider.accessType {
                case .openBanking:
                    self?.tinkLinkTracker.track(applicationEvent: .providerAuthenticationInitialized)
                case .other:
                    self?.tinkLinkTracker.track(applicationEvent: .credentialsSubmitted)
                default: break
                }
            }

            addCredentialsSession.updateCredentials(credentials: fetchedCredentials, form: form) { [weak self] result in
                self?.handleCompletion(for: result.map { ($0, nil) })
            }

        case .authenticate, .refresh:
            break
        }
        tinkLinkTracker.track(interaction: .submitCredentials, screen: .submitCredentials)
    }
}

extension CredentialsCoordinator: ScopeDescriptionListViewControllerDelegate {
    func scopeDescriptionListViewController(viewController: ScopeDescriptionListViewController, error: Error) {
        presenter?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Actions

extension CredentialsCoordinator {
    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        presenter?.dismiss(animated: true, completion: nil)
    }

    @objc private func cancel() {
        if !credentialsController.newlyAddedFailedCredentialsID.isEmpty {
            completion(.failure(TinkLinkUIError(code: .failedToAddCredentials, errorsByCredentialsID: credentialsController.newlyAddedFailedCredentialsID)))
        } else {
            completion(.failure(TinkLinkUIError(code: .userCancelled)))
        }
    }
}

// MARK: - Alerts

extension CredentialsCoordinator {
    private func showDownloadPrompt(for thirdPartyAppAuthenticationError: TinkLinkError.ThirdPartyAppAuthenticationFailureReason) {
        let alertController = UIAlertController(title: thirdPartyAppAuthenticationError.errorDescription, message: thirdPartyAppAuthenticationError.failureReason, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthenticationError.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL), !callCompletionOnError {
            let cancelAction = UIAlertAction(title: Strings.Generic.cancel, style: .cancel)
            let downloadAction = UIAlertAction(title: Strings.ThirdPartyAppAuthentication.DownloadAlert.download, style: .default, handler: { _ in
                UIApplication.shared.open(appStoreURL)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: Strings.Generic.dismiss, style: .default) { _ in
                if self.callCompletionOnError {
                    self.completion(.failure(TinkLinkUIError(code: .unableToOpenThirdPartyApp)))
                }
            }
            alertController.addAction(okAction)
        }

        presenter?.present(alertController, animated: true, completion: nil)
    }

    private func showAlert(for error: Error, completion: (() -> Void)? = nil) {
        let title: String
        let message: String?
        if let error = error as? LocalizedError {
            title = error.errorDescription ?? Strings.Generic.error
            message = error.failureReason
        } else {
            title = Strings.Generic.error
            message = error.localizedDescription
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: Strings.Generic.ok, style: .default) { _ in
            if self.callCompletionOnError {
                self.completion(.failure(TinkLinkUIError(code: .internalError)))
            } else {
                completion?()
            }
        }
        alertController.addAction(okAction)

        presenter?.forcePresent(alertController, animated: true, completion: nil)
    }
}
