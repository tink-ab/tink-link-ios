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
/// Here's how you can start the aggregation flow via TinkLinkUI with the TinkLinkViewController:
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

    public enum Operation {
        case create(providerPredicate: ProviderPredicate)
        case authenticate(credentialsID: Credentials.ID)
        case refresh(credentialsID: Credentials.ID)
        case update(credentialsID: Credentials.ID)
    }

    public enum ResultType {
        case credentials(Credentials)
        case authorizationCode(AuthorizationCode)
    }

    public var operation: Operation?
    public var accessToken: AccessToken?

    /// The prefilling strategy to use.
    public var prefill: PrefillStrategy = .none
    /// Scopes that grant access to Tink.
    public let scopes: [Scope]?
    private let tink: Tink
    private let market: Market?
    private let providerPredicate: ProviderPredicate
    private var providerController: ProviderController
    private lazy var credentialsController = CredentialsController(tink: tink)
    private lazy var authorizationController = AuthorizationController(tink: tink)

    private lazy var addCredentialsSession = AddCredentialsSession(providerController: self.providerController, credentialsController: self.credentialsController, authorizationController: self.authorizationController, scopes: scopes ?? [], parentViewController: self)
    private lazy var providerPickerCoordinator = ProviderPickerCoordinator(parentViewController: self, providerController: providerController)
    private lazy var loadingViewController = LoadingViewController(providerController: providerController)

    private var clientDescription: ClientDescription?
    private let clientDescriptorLoadingGroup = DispatchGroup()
    private var result: Result<ResultType, TinkLinkError>?
    private let temporaryCompletion: ((Result<AuthorizationCode, TinkLinkError>) -> Void)?
    private let permamentCompletion: ((Result<Credentials, TinkLinkError>) -> Void)?

    /// Initializes a new TinkLinkViewController.
    /// - Parameters:
    ///   - tink: A configured `Tink` object.
    ///   - market: The market you wish to aggregate from. Will determine what providers are available to choose from. 
    ///   - scope: A set of scopes that will be aggregated.
    ///   - providerKinds: The kind of providers that will be listed.
    ///   - providerPredicate: The predicate of a provider. Either `kinds`or `name` depending on if the goal is to fetch all or just one specific provider.
    ///   - completion: The block to execute when the aggregation finished or if an error occurred.
    public init(tink: Tink = .shared, market: Market, scopes: [Scope], providerPredicate: ProviderPredicate = .kinds(.defaultKinds), completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
        self.tink = tink
        self.market = market
        self.scopes = scopes
        self.providerController = ProviderController(tink: tink, providerPredicate: providerPredicate)
        self.providerPredicate = providerPredicate
        self.temporaryCompletion = completion
        self.permamentCompletion = nil

        super.init(nibName: nil, bundle: nil)
    }

    public init(tink: Tink = .shared, accessToken: AccessToken, operation: Operation, completion: @escaping (Result<Credentials, TinkLinkError>) -> Void) {
        self.tink = tink
        self.accessToken = accessToken
        self.operation = operation
        self.scopes = nil
        self.market = nil
        self.providerPredicate = .kinds(.all)
        self.providerController = ProviderController(tink: tink)
        self.permamentCompletion = completion
        self.temporaryCompletion = nil

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, deprecated, message: "use tink:market:scopes:providerPredicate: instead")
    public convenience init(tink: Tink = .shared, market: Market, scopes: [Scope], providerKinds: Set<Provider.Kind> = .defaultKinds, completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
        self.init(tink: tink, market: market, scopes: scopes, providerPredicate: .kinds(providerKinds), completion: completion)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()

        view.backgroundColor = Color.background
        loadingViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        setViewControllers([loadingViewController], animated: false)

        presentationController?.delegate = self
        loadingViewController.delegate = self

        start(accessToken: accessToken)
    }

    func fetchProviders() {
        providerController.fetch { (result) in
            DispatchQueue.main.async {
                self.loadingViewController.hideLoadingIndicator()
                switch result {
                case .success(let providers):
                    self.setViewControllers([], animated: false)
                    switch self.providerPredicate {
                    case .kinds:
                        self.showProviderPicker()
                    case .name:
                        if let provider = providers.first {
                            self.showAddCredentials(for: provider, animated: false)
                        }
                    }
                case .failure (let error):
                    if let tinkLinkError = TinkLinkError(error: error) {
                        self.result = .failure(tinkLinkError)
                    }
                    self.loadingViewController.update(error)
                }
            }
        }
    }

    private func start(accessToken: AccessToken?) {
        loadingViewController.showLoadingIndicator()
        tink._beginUITask()
        defer { tink._endUITask() }
        if let accessToken = accessToken {
            authorizePermanentUser(accessToken: accessToken)
        } else {
            createTemporaryUser()
        }
    }

    private func authorizePermanentUser(accessToken: AccessToken) {
        tink.userSession = .accessToken(accessToken.rawValue)
        tink.authenticateUser(authorizationCode: AuthorizationCode("AUTHORIZATION_CODE")) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    _ = try result.get()

                    self.fetchProviders()
                    self.clientDescriptorLoadingGroup.enter()
                    self.authorizationController.clientDescription { (clientDescriptionResult) in
                        DispatchQueue.main.async {
                            do {
                                self.clientDescription = try clientDescriptionResult.get()
                                self.clientDescriptorLoadingGroup.leave()
                            } catch {
                                self.showUnknownAggregatorAlert(for: error)
                            }
                        }
                    }
                } catch {
                    let viewController = UIViewController()
                    self.setViewControllers([viewController], animated: false)
                    self.showCreateTemporaryUserAlert(for: error)
                }
            }
        }
    }

    private func createTemporaryUser() {
        guard let market = market else { return }
        tink._createTemporaryUser(for: market) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    _ = try result.get()

                    self.fetchProviders()
                    self.clientDescriptorLoadingGroup.enter()
                    self.authorizationController.clientDescription { (clientDescriptionResult) in
                        DispatchQueue.main.async {
                            do {
                                self.clientDescription = try clientDescriptionResult.get()
                                self.clientDescriptorLoadingGroup.leave()
                            } catch {
                                self.showUnknownAggregatorAlert(for: error)
                            }
                        }
                    }
                } catch {
                    let viewController = UIViewController()
                    self.setViewControllers([viewController], animated: false)
                    self.showCreateTemporaryUserAlert(for: error)
                }
            }
        }
    }

    @objc private func cancel() {
        if didShowAddCredentialForm {
            showDiscardActionSheet()
        } else {
            closeTinkLink()
        }
    }

    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    private func closeTinkLink() {
        completion()
        dismiss(animated: true)
    }

    private func completion() {
        if let result = result {
            switch result {
            case .success(let resultType):
                switch resultType {
                case .authorizationCode(let authorizationCode):
                    temporaryCompletion?(.success(authorizationCode))
                case .credentials(let credentials):
                    permamentCompletion?(.success(credentials))
                }
            case .failure(let error):
                temporaryCompletion?(.failure(error))
                permamentCompletion?(.failure(error))
            }
        } else {
            temporaryCompletion?(.failure(.userCancelled))
            permamentCompletion?(.failure(.userCancelled))
        }
    }
}

// MARK: - Alerts

extension TinkLinkViewController {

    private func showCreateTemporaryUserAlert(for error: Error) {
        let localizedError = error as? LocalizedError

        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? Strings.Generic.ServiceAlert.fallbackTitle,
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )
        loadingViewController.hideLoadingIndicator()
        let retryAction = UIAlertAction(title: Strings.Generic.ServiceAlert.retry, style: .default) { _ in
            self.loadingViewController.showLoadingIndicator()
            self.setViewControllers([self.loadingViewController], animated: false)
            self.start(accessToken: self.accessToken)
        }
        alertController.addAction(retryAction)

        let dismissAction = UIAlertAction(title: Strings.Generic.Alert.dismiss, style: .cancel) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    private func showUnknownAggregatorAlert(for error: Error) {
        let localizedError = error as? LocalizedError

        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? Strings.Generic.ServiceAlert.fallbackTitle,
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let dismissAction = UIAlertAction(title: Strings.Generic.Alert.dismiss, style: .cancel) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
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

        present(alertController, animated: true)
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

        present(alertController, animated: true)
    }

}

//MARK: - Navigation

extension TinkLinkViewController {

    private func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        var newViewControllers = viewControllers
        _ = newViewControllers.popLast()
        newViewControllers.append(viewController)
        setViewControllers(newViewControllers, animated: animated)
    }

    func showProviderPicker() {
        providerPickerCoordinator.start { [weak self] (result) in
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
        guard let clientDescription = clientDescription else {
            clientDescriptorLoadingGroup.notify(queue: .main) { [weak self] in
                self?.showAddCredentials(for: provider, animated: animated)
            }
            loadingViewController.showLoadingIndicator()
            show(loadingViewController, sender: nil)
            return
        }
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsController: credentialsController, clientName: clientDescription.name, isAggregator: clientDescription.isAggregator, isVerified: clientDescription.isVerified)
        addCredentialsViewController.prefillStrategy = prefill
        addCredentialsViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        addCredentialsViewController.delegate = self
        if viewControllers.last is LoadingViewController {
            replaceTopViewController(with: addCredentialsViewController, animated: true)
        } else {
            show(addCredentialsViewController, sender: nil)
        }
    }

    func showAddCredentialSuccess() {
        guard let clientDescription = clientDescription else {
            clientDescriptorLoadingGroup.notify(queue: .main) { [weak self] in
                self?.showAddCredentialSuccess()
            }
            loadingViewController.showLoadingIndicator()
            show(loadingViewController, sender: nil)
            return
        }
        let viewController = CredentialsSuccessfullyAddedViewController(companyName: clientDescription.name) { [weak self] in
            guard let self = self else { return }
            self.completion()
            self.dismiss(animated: true)
        }
        setViewControllers([viewController], animated: true)
    }
}

// MARK: - LoadingViewControllerDelegate

extension TinkLinkViewController: LoadingViewControllerDelegate {
    func loadingViewControllerDidPressRetry(_ viewController: LoadingViewController) {
        loadingViewController.showLoadingIndicator()
        fetchProviders()
    }
}

// MARK: - AddCredentialsViewControllerDelegate

extension TinkLinkViewController: AddCredentialsViewControllerDelegate {
    func showScopeDescriptions() {
        let viewController = ScopeDescriptionListViewController(authorizationController: authorizationController, scopes: scopes ?? [])
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMoreInfo))
        let navigationController = TinkNavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    func showWebContent(with url: URL) {
        let viewController = LegalViewController(url: url)
        present(viewController, animated: true)
    }

    func addCredential(provider: Provider, form: Form) {
        addCredentialsSession.addCredential(provider: provider, form: form) { [weak self] result in
            do {
                let authorizationCode = try result.get()
                self?.result = .success(ResultType.authorizationCode(authorizationCode))
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
}

// MARK: - Helpers
extension TinkLinkViewController {
    private var didShowAddCredentialForm: Bool {
        viewControllers.contains(where: { $0 is AddCredentialsViewController })
    }

    private func showDiscardActionSheet() {
        let alertTitle = Strings.AddCredentials.Discard.title
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)

        let discardActionTitle = Strings.AddCredentials.Discard.primaryAction
        let discardAction = UIAlertAction(title: discardActionTitle, style: .destructive) { _ in
            self.closeTinkLink()
        }
        alert.addAction(discardAction)

        let continueActionTitle = Strings.AddCredentials.Discard.continueAction
        let continueAction = UIAlertAction(title: continueActionTitle, style: .cancel)
        alert.addAction(continueAction)

        present(alert, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
/// :nodoc:
@available(iOS 13.0, *)
extension TinkLinkViewController: UIAdaptivePresentationControllerDelegate {
    /// :nodoc:
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDiscardActionSheet()
    }

    /// :nodoc:
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        completion()
    }

    /// :nodoc:
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !didShowAddCredentialForm
    }
}
