import UIKit
import TinkLink

/// A view controller for aggregating credentials.
///
/// A `TinkLinkViewController` displays adding bank credentials.
/// To start using Tink Link UI, you need to first configure a `Tink` instance with your client ID and redirect URI.
///
/// Typically you do this in your app's `application(_:didFinishLaunchingWithOptions:)` method like this.
///
/// ```swift
/// import UIKit
/// import TinkLink
/// @UIApplicationMain
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///
///    var window: UIWindow?
///
///    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///
///        let configuration = try! Tink.Configuration(clientID: <#String#>, redirectURI: <#URL#>)
///        Tink.configure(with: configuration)
///        ...
/// ```
///
/// Here's one way you can start the aggregation flow via TinkLinkUI with the TinkLinkViewController:
/// You need to define scopes based on the type of data you want to fetch. For example, to fetch accounts and transactions, define these scopes. Then create a `TinkLinkViewController` with a market and the scopes to use. And present the view controller.
/// ```swift
/// let scopes: [Scope] = [
///     .accounts(.read),
///     .transactions(.read)
/// ]
///
/// let tinkLinkViewController = TinkLinkViewController(market: <#String#>, scopes: scopes) { result in
///    // Handle result
/// }
/// present(tinkLinkViewController, animated: true)
/// ```
///
/// You can also start the aggregation flow if you have an authorization code or an access token:
/// ```swift
/// // With authorization code:
/// let authorizationCode = "YOUR_AUTHORIZATION_CODE"
/// let tinkLinkViewController = TinkLinkViewController(authorizationCode: AuthorizationCode(authorizationCode)) { result in
///     // Handle result
/// }
/// present(tinkLinkViewController, animated: true)
///
/// // With access token:
/// let accessToken = "YOUR_ACCESS_TOKEN"
/// let tinkLinkViewController = TinkLinkViewController(userSession: .accessToken(accessToken)) { result in
///     // Handle result
/// }
///
/// present(tinkLinkViewController, animated: true)
/// ```
///
/// After the user has completed or cancelled the aggregation flow, the completion handler will be called with a result. On a successful authentication the result will contain an authorization code that you can [exchange](https://docs.tink.com/resources/getting-started/retrieve-access-token) for an access token. If something went wrong the result will contain an error.
/// ```swift
/// do {
///     let authorizationCode = try result.get()
///     // Exchange the authorization code for a access token.
/// } catch {
///     // Handle any errors
/// }
/// ```
public class TinkLinkViewController: UINavigationController {
    /// Strategy for different types of prefilling
    public enum PrefillStrategy {
        /// No prefilling will occur.
        case none
        /// Will attempt to fill the first field of the provider with the associated value if it is valid.
        case username(value: String, isEditable: Bool)
    }

    /// Strategy for what to fetch
    public enum ProviderPredicate {
        /// Will fetch a list of providers depending on kind.
        case kinds(Set<Provider.Kind>)
        /// Will fetch a single provider by id.
        case name(Provider.ID)
    }

    /// Strategy for different operations.
    public enum Operation {
        /// Create credentials.
        case create(providerPredicate: ProviderPredicate = .kinds(.default))
        /// Authenticate credentials.
        case authenticate(credentialsID: Credentials.ID)
        /// Refresh credentials.
        case refresh(credentialsID: Credentials.ID)
        /// Update credentials.
        case update(credentialsID: Credentials.ID)
    }

    enum ResultType {
        case credentials(Credentials)
        case authorizationCode(AuthorizationCode)
    }

    private let operation: Operation
    private var userSession: UserSession?
    private var authorizationCode: AuthorizationCode?
    private var userHasConnected: Bool = false

    /// The prefilling strategy to use.
    public var prefill: PrefillStrategy = .none
    /// Scopes that grant access to Tink.
    public let scopes: [Scope]?
    private let tink: Tink
    private let market: Market?
    private lazy var providerController = ProviderController(tink: tink)
    private lazy var credentialsController = CredentialsController(tink: tink)
    private lazy var authorizationController = AuthorizationController(tink: tink)
    private lazy var providerPickerCoordinator = ProviderPickerCoordinator(parentViewController: self, providerController: providerController)

    private var loadingViewController: LoadingViewController?

    private var credentialsCoordinator: CredentialsCoordinator?
    private var clientDescription: ClientDescription?
    private let clientDescriptorLoadingGroup = DispatchGroup()
    private var result: Result<ResultType, TinkLinkError>?
    private let temporaryCompletion: ((Result<AuthorizationCode, TinkLinkError>) -> Void)?
    private let permanentCompletion: ((Result<Credentials, TinkLinkError>) -> Void)?

    /// Initializes a new TinkLinkViewController.
    /// - Parameters:
    ///   - tink: A configured `Tink` object.
    ///   - market: The market you wish to aggregate from. Will determine what providers are available to choose from.
    ///   - scope: A set of scopes that will be aggregated.
    ///   - providerKinds: The kind of providers that will be listed.
    ///   - providerPredicate: The predicate of a provider. Either `kinds`or `name` depending on if the goal is to fetch all or just one specific provider.
    ///   - completion: The block to execute when the aggregation finished or if an error occurred.
    public init(tink: Tink = .shared, market: Market, scopes: [Scope], providerPredicate: ProviderPredicate = .kinds(.default), completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
        self.tink = tink
        self.market = market
        self.scopes = scopes
        self.operation = .create(providerPredicate: providerPredicate)
        self.temporaryCompletion = completion
        self.permanentCompletion = nil

        super.init(nibName: nil, bundle: nil)
    }

    /// Initializes a new TinkLinkViewController with the current user session associated with this Tink object.
    /// - Parameters:
    ///   - tink: A configured `Tink` object.
    ///   - userSession: The user session associated with the TinkLinkViewController.
    ///   - operation: The operation to do. You can either `create`, `authenticate`, `refresh` or `update`.
    ///   - completion: The block to execute when the aggregation finished or if an error occurred.
    public init(tink: Tink = .shared, userSession: UserSession, operation: Operation = .create(providerPredicate: .kinds(.default)), completion: @escaping (Result<Credentials, TinkLinkError>) -> Void) {
        self.tink = tink
        self.userSession = userSession
        self.operation = operation
        self.scopes = nil
        self.market = nil
        self.permanentCompletion = completion
        self.temporaryCompletion = nil

        super.init(nibName: nil, bundle: nil)
    }

    /// Initializes a new TinkLinkViewController with the `AuthorizationCode`.
    /// - Parameters:
    ///   - tink: A configured `Tink` object.
    ///   - authorizationCode: Authenticate with a `AuthorizationCode` that delegated from Tink to exchanged for a user object.
    ///   - operation: The operation to do. You can either `create`, `authenticate`, `refresh` or `update`.
    ///   - completion: The block to execute when the aggregation finished or if an error occurred.
    public init(tink: Tink = .shared, authorizationCode: AuthorizationCode, operation: Operation = .create(providerPredicate: .kinds(.default)), completion: @escaping (Result<Credentials, TinkLinkError>) -> Void) {
        self.tink = tink
        self.authorizationCode = authorizationCode
        self.operation = operation
        self.userSession = nil
        self.scopes = nil
        self.market = nil
        self.permanentCompletion = completion
        self.temporaryCompletion = nil

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, deprecated, message: "use tink:market:scopes:providerPredicate: instead")
    public convenience init(tink: Tink = .shared, market: Market, scopes: [Scope], providerKinds: Set<Provider.Kind>, completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
        self.init(tink: tink, market: market, scopes: scopes, providerPredicate: .kinds(providerKinds), completion: completion)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()

        view.backgroundColor = Color.background

        showLoadingOverlay(withText: nil, animated: false, onCancel: nil)

        presentationController?.delegate = self

        start(userSession: userSession, authorizationCode: authorizationCode)
    }

    public override func show(_ vc: UIViewController, sender: Any?) {
        hideLoadingOverlay(animated: false)
        super.show(vc, sender: sender)
    }

    private func start(userSession: UserSession?, authorizationCode: AuthorizationCode?) {
        tink._beginUITask()
        defer { tink._endUITask() }
        if let userSession = userSession {
            tink.userSession = userSession
            startOperation()
        } else if let authorizationCode = authorizationCode {
            authorizePermanentUser(authorizationCode: authorizationCode) {
                self.startOperation()
            }
        } else {
            createTemporaryUser {
                self.startOperation()
            }
        }
    }

    private func authorizePermanentUser(authorizationCode: AuthorizationCode, completion: @escaping () -> Void) {
        tink.authenticateUser(authorizationCode: authorizationCode) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    _ = try result.get()

                    completion()
                } catch {
                    let viewController = UIViewController()
                    self.setViewControllers([viewController], animated: false)
                    self.showAlert(for: error, onRetry: {
                        self.retryOperation()
                    })
                }
            }
        }
    }

    private func createTemporaryUser(completion: @escaping () -> Void) {
        guard let market = market else { return }
        tink._createTemporaryUser(for: market) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    _ = try result.get()

                    completion()
                } catch {
                    let viewController = UIViewController()
                    self.setViewControllers([viewController], animated: false)
                    self.showAlert(for: error, onRetry: {
                        self.retryOperation()
                    })
                }
            }
        }
    }

    private func startOperation() {
        DispatchQueue.main.async {
            self.operate()
            self.clientDescriptorLoadingGroup.enter()
            self.authorizationController.clientDescription { clientDescriptionResult in
                DispatchQueue.main.async {
                    do {
                        self.clientDescription = try clientDescriptionResult.get()
                        self.clientDescriptorLoadingGroup.leave()
                    } catch {
                        self.showAlert(for: error, onRetry: nil)
                    }
                }
            }
        }
    }

    func operate() {
        switch operation {
        case .create(providerPredicate: let providerPredicate):
            fetchProviders(providerPredicate: providerPredicate)
        case .authenticate(let id):
            startCredentialCoordinator(with: .authenticate(credentialsID: id))
        case .refresh(let id):
            startCredentialCoordinator(with: .refresh(credentialsID: id))
        case .update(let id):
            startCredentialCoordinator(with: .update(credentialsID: id))
        }
    }

    func fetchProviders(providerPredicate: ProviderPredicate) {
        providerController.fetch(with: providerPredicate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let providers):
                    switch providerPredicate {
                    case .kinds:
                        self.showProviderPicker()
                    case .name:
                        if let provider = providers.first {
                            self.showAddCredentials(for: provider, animated: false)
                        }
                    }
                case .failure(let error):
                    if let tinkLinkError = TinkLinkError(error: error) {
                        self.result = .failure(tinkLinkError)
                    }
                    self.loadingViewController?.setError(error, onClose: { [weak self] in
                        self?.loadingViewController?.hideLoadingIndicator()
                        self?.result = .failure(.userCancelled)
                        self?.closeTinkLink()
                    }, onRetry: { [weak self] in
                        self?.loadingViewController?.showLoadingIndicator()
                        self?.operate()
                    })
                }
            }
        }
    }

    func startCredentialCoordinator(with operation: CredentialsCoordinator.Action) {
        guard let clientDescription = clientDescription else {
            clientDescriptorLoadingGroup.notify(queue: .main) { [weak self] in
                self?.startCredentialCoordinator(with: operation)
            }
            showLoadingOverlay(withText: nil, animated: false, onCancel: nil)
            return
        }

        credentialsCoordinator = CredentialsCoordinator(authorizationController: authorizationController, credentialsController: credentialsController, providerController: providerController, presenter: self, delegate: self, clientDescription: clientDescription, action: operation, completion: { [weak self] result in
            let mappedResult = result.map { (credentials, code) -> ResultType in
                if let code = code {
                    return .authorizationCode(code)
                } else {
                    return .credentials(credentials)
                }
            }
            self?.result = mappedResult
            self?.completionHandler()
            self?.dismiss(animated: true)
            self?.credentialsCoordinator = nil
        })
        credentialsCoordinator?.start()
    }

    @objc private func cancel() {
        if didShowCredentialsForm {
            showDiscardActionSheet()
        } else {
            closeTinkLink()
        }
    }

    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    private func closeTinkLink() {
        completionHandler()
        dismiss(animated: true)
    }

    private func completionHandler() {
        switch result {
        case .success(.credentials(let credentials)):
            permanentCompletion?(.success(credentials))

        case .success(.authorizationCode(let code)):
            temporaryCompletion?(.success(code))

        case .failure(let error):
            temporaryCompletion?(.failure(error))
            permanentCompletion?(.failure(error))

        case .none:
            temporaryCompletion?(.failure(.userCancelled))
            permanentCompletion?(.failure(.userCancelled))
        }
    }
}

// MARK: - Alerts

extension TinkLinkViewController {
    private func showAlert(for error: Error, onRetry: (() -> Void)? = nil) {
        let title: String?
        let message: String?

        if let error = error as? LocalizedError {
            title = error.errorDescription
            message = error.failureReason
        } else {
            title = Strings.Generic.error
            message = error.localizedDescription
        }

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        if let onRetry = onRetry {
            let retryAction = UIAlertAction(title: Strings.Generic.retry, style: .default) { _ in
                onRetry()
            }
            alertController.addAction(retryAction)
        }

        let dismissAction = UIAlertAction(title: Strings.Generic.dismiss, style: .cancel) { _ in
            self.completionHandler()
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    private func retryOperation() {
        showLoadingOverlay(withText: nil, onCancel: nil)
        start(userSession: userSession, authorizationCode: authorizationCode)
    }
}

// MARK: - Navigation

extension TinkLinkViewController {
    func showProviderPicker() {
        providerPickerCoordinator.start { [weak self] result in
            do {
                let provider = try result.get()
                self?.showAddCredentials(for: provider)
            } catch CocoaError.userCancelled {
                self?.cancel()
            } catch {
                self?.showAlert(for: error)
            }
        }
    }

    func showAddCredentials(for provider: Provider, animated: Bool = true) {
        if let scopes = scopes {
            startCredentialCoordinator(with: .create(provider: provider, mode: .anonymous(scopes: scopes)))
        } else {
            startCredentialCoordinator(with: .create(provider: provider, mode: .user))
        }
    }

    func showLoadingOverlay(withText text: String?, animated: Bool = true, onCancel: (() -> Void)?) {
        guard loadingViewController == nil else {
            loadingViewController?.update(text, onCancel: onCancel)
            return
        }

        let loadingViewController = LoadingViewController()
        loadingViewController.view.translatesAutoresizingMaskIntoConstraints = false

        loadingViewController.willMove(toParent: self)
        loadingViewController.beginAppearanceTransition(true, animated: animated)
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self)

        loadingViewController.update(text, onCancel: onCancel)
        loadingViewController.showLoadingIndicator()

        self.loadingViewController = loadingViewController

        NSLayoutConstraint.activate([
            loadingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if animated {
            loadingViewController.view.alpha = 0.0
            UIView.animate(withDuration: 0.1, animations: {
                loadingViewController.view.alpha = 1.0
            }, completion: { _ in
                loadingViewController.endAppearanceTransition()
            })
        } else {
            loadingViewController.endAppearanceTransition()
        }
    }

    func hideLoadingOverlay(animated: Bool = true) {
        guard let loadingViewController = loadingViewController else { return }

        loadingViewController.beginAppearanceTransition(false, animated: animated)

        let removeView = {
            loadingViewController.view.removeFromSuperview()
            loadingViewController.removeFromParent()
            loadingViewController.endAppearanceTransition()
            self.loadingViewController = nil
        }

        if animated {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1, animations: {
                    loadingViewController.view.alpha = 0.0
                }, completion: { _ in
                    removeView()
                })
            }
        } else {
            removeView()
        }
    }
}

// MARK: - Helpers

extension TinkLinkViewController {
    private var didShowCredentialsForm: Bool {
        credentialsCoordinator != nil
    }

    private func showDiscardActionSheet() {
        let alertTitle = Strings.Credentials.Discard.title
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)

        let discardActionTitle = Strings.Credentials.Discard.primaryAction
        let discardAction = UIAlertAction(title: discardActionTitle, style: .destructive) { _ in
            self.closeTinkLink()
        }
        alert.addAction(discardAction)

        let continueActionTitle = Strings.Credentials.Discard.continueAction
        let continueAction = UIAlertAction(title: continueActionTitle, style: .cancel)
        alert.addAction(continueAction)

        present(alert, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

@available(iOS 13.0, *)
extension TinkLinkViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if !userHasConnected {
            showDiscardActionSheet()
        }
    }

    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        completionHandler()
    }

    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !didShowCredentialsForm
    }
}

extension TinkLinkViewController: CredentialsCoordinatorPresenting {
    func showLoadingIndicator(text: String?, onCancel: (() -> Void)?) {
        showLoadingOverlay(withText: text, onCancel: onCancel)
    }

    func hideLoadingIndicator() {
        hideLoadingOverlay()
    }

    func show(_ viewController: UIViewController) {
        show(viewController, sender: self)
    }
}

// MARK: - CredentialsCoordinatorDelegate

extension TinkLinkViewController: CredentialsCoordinatorDelegate {
    func didFinishCredentialsForm() {
        userHasConnected = true
    }
}
