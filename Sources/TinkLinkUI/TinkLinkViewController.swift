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
    /// Scopes that grant access to Tink.
    public let scopes: [Scope]

    private let tink: Tink
    private let market: Market
    private var providerController: ProviderController
    private lazy var credentialsController = CredentialsController(tink: tink)
    private lazy var authorizationController = AuthorizationController(tink: tink)

    private lazy var addCredentialsSession = AddCredentialsSession(providerController: self.providerController, credentialsController: self.credentialsController, authorizationController: self.authorizationController, scopes: scopes, parentViewController: self)
    private lazy var providerPickerCoordinator = ProviderPickerCoordinator(parentViewController: self, providerController: providerController)
    private lazy var loadingViewController = LoadingViewController(providerController: providerController)

    private var clientDescription: ClientDescription?
    private let clientDescriptorLoadingGroup = DispatchGroup()
    private var result: Result<AuthorizationCode, TinkLinkError>?
    private let completion: (Result<AuthorizationCode, TinkLinkError>) -> Void

    /// Initializes a new TinkLinkViewController.
    /// - Parameters:
    ///   - tink: A configured `Tink` object.
    ///   - market: The market you wish to aggregate from. Will determine what providers are available to choose from. 
    ///   - scope: A set of scopes that will be aggregated.
    ///   - providerKinds: The kind of providers that will be listed.
    ///   - completion: The block to execute when the aggregation finished or if an error occurred.
    public init(tink: Tink = .shared, market: Market, scopes: [Scope], providerKinds: Set<Provider.Kind> = .defaultKinds, completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
        self.tink = tink
        self.market = market
        self.scopes = scopes
        self.providerController = ProviderController(tink: tink, providerKinds: providerKinds)
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
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
        providerPickerCoordinator.delegate = self

        start()
    }

    private func start() {
        tink._beginUITask()
        defer { tink._endUITask() }
        tink._createTemporaryUser(for: market) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    _ = try result.get()

                    self.providerController.performFetch()
                    self.showProviderPicker()
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
        completion(result ?? .failure(.userCancelled))
        dismiss(animated: true)
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
            self.start()
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

    func showAddCredentials(for provider: Provider) {
        guard let clientDescription = clientDescription else {
            clientDescriptorLoadingGroup.notify(queue: .main) { [weak self] in
                self?.showAddCredentials(for: provider)
            }
            loadingViewController.showLoadingIndicator()
            show(loadingViewController, sender: nil)
            return
        }
        let addCredentialsViewController = AddCredentialsViewController(provider: provider, credentialsController: credentialsController, clientName: clientDescription.name, isAggregator: clientDescription.isAggregator, isVerified: clientDescription.isVerified)
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
            guard let self = self, let result = self.result else { return }
            self.completion(result)
            self.dismiss(animated: true)
        }
        setViewControllers([viewController], animated: true)
    }
}

// MARK: - ProviderPickerCoordinatorDelegate
extension TinkLinkViewController: ProviderPickerCoordinatorDelegate {
    func providerPickerCoordinatorShowLoading(_ coordinator: ProviderPickerCoordinator) {
        loadingViewController.showLoadingIndicator()
    }

    func providerPickerCoordinatorHideLoading(_ coordinator: ProviderPickerCoordinator) {
        loadingViewController.hideLoadingIndicator()
    }

    func providerPickerCoordinatorUpdateProviders(_ coordinator: ProviderPickerCoordinator) {
        DispatchQueue.main.async {
            self.loadingViewController.removeFromParent()
        }
    }

    func providerPickerCoordinatorShowError(_ coordinator: ProviderPickerCoordinator, error: Error?) {
        if let tinkLinkError = error.flatMap({ TinkLinkError(error: $0) }) {
            self.result = .failure(tinkLinkError)
        }
        loadingViewController.update(error)
    }
}

// MARK: - AddCredentialsViewControllerDelegate

extension TinkLinkViewController: AddCredentialsViewControllerDelegate {
    func showScopeDescriptions() {
        let viewController = ScopeDescriptionListViewController(authorizationController: authorizationController, scopes: scopes)
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
                self?.result = .success(authorizationCode)
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
        completion(result ?? .failure(.userCancelled))
    }

    /// :nodoc:
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !didShowAddCredentialForm
    }
}
