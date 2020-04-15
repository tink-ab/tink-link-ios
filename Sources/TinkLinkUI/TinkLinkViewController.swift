import UIKit
import TinkLink

public class TinkLinkViewController: UINavigationController {
    private let tink: Tink
    private let market: Market
    public let scopes: [Scope]

    private var providerController: ProviderController
    private lazy var credentialsController = CredentialsController(tink: tink)
    private lazy var authorizationController = AuthorizationController(tink: tink)

    private lazy var addCredentialsSession = AddCredentialSession(providerController: self.providerController, credentialsController: self.credentialsController, authorizationController: self.authorizationController, scopes: scopes, parentViewController: self)
    private lazy var providerPickerCoordinator = ProviderPickerCoordinator(parentViewController: self, providerController: providerController)
    private lazy var loadingViewController = LoadingViewController(providerController: providerController)

    private var clientDescription: ClientDescription?
    private let clientDescriptorLoadingGroup = DispatchGroup()
    private var result: Result<AuthorizationCode, TinkLinkError>?
    private let completion: (Result<AuthorizationCode, TinkLinkError>) -> Void

    public init(tink: Tink = .shared, market: Market, scopes: [Scope], providerKinds: Set<Provider.Kind> = .defaultKinds, authorization completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
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
        tink.createTemporaryUser(for: market) { [weak self] result in
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
            title: localizedError?.errorDescription ?? NSLocalizedString("Generic.ServiceAlert.FallbackTitle", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "The service is unavailable at the moment.", comment: "Title for error alert if error doesn't contain a description."),
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )
        loadingViewController.hideLoadingIndicator()
        let retryAction = UIAlertAction(title: NSLocalizedString("Generic.ServiceAlert.Retry", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Retry", comment: "Title for action to retry a failed request."), style: .default) { _ in
            self.loadingViewController.showLoadingIndicator()
            self.setViewControllers([self.loadingViewController], animated: false)
            self.start()
        }
        alertController.addAction(retryAction)

        let dismissAction = UIAlertAction(title: NSLocalizedString("Generic.Alert.Dismiss", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Dismiss", comment: "Title for action to dismiss error alert."), style: .cancel) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    private func showUnknownAggregatorAlert(for error: Error) {
        let localizedError = error as? LocalizedError

        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? NSLocalizedString("Generic.ServiceAlert.FallbackTitle", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "The service is unavailable at the moment.", comment: "Title for error alert if error doesn't contain a description."),
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let dismissAction = UIAlertAction(title: NSLocalizedString("Generic.Alert.Dismiss", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Dismiss", comment: "Title for action to dismiss error alert."), style: .cancel) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    private func showDownloadPrompt(for thirdPartyAppAuthenticationError: ThirdPartyAppAuthenticationTask.Error) {
        let alertController = UIAlertController(title: thirdPartyAppAuthenticationError.errorDescription, message: thirdPartyAppAuthenticationError.failureReason, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthenticationError.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
            let cancelAction = UIAlertAction(title: NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Cancel", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Cancel", comment: "Title for action to cancel downloading app for third-party app authentication."), style: .cancel)
            let downloadAction = UIAlertAction(title: NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Download", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Download", comment: "Title for action to download app for third-party app authentication."), style: .default, handler: { _ in
                UIApplication.shared.open(appStoreURL)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Dismiss", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "OK", comment: "Title for action to confirm alert requesting download of third-party authentication app when AppStore URL could not be opened."), style: .default)
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
            title = NSLocalizedString("Generic.Alert.Title", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Error", comment: "Title generic alert.")
            message = error.localizedDescription
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: NSLocalizedString("Generic.Alert.OK", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "OK", comment: "Title for action to confirm alert."), style: .default)
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
                self?.showAddCredential(for: provider)
            } catch CocoaError.userCancelled {
                self?.cancel()
            } catch {
                self?.showAlert(for: error)
            }
        }
    }

    func showAddCredential(for provider: Provider) {
        guard let clientDescription = clientDescription else {
            clientDescriptorLoadingGroup.notify(queue: .main) { [weak self] in
                self?.showAddCredential(for: provider)
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
        addCredentialSession.addCredential(provider: provider, form: form) { [weak self] result in
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
        let alertTitle = NSLocalizedString("AddCredentials.Discard.Title", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Are you sure you want to discard this new credential?", comment: "Title for action sheet presented when user tries to dismiss modal while adding credentials.")
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)

        let discardActionTitle = NSLocalizedString("AddCredentials.Discard.PrimaryAction", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Discard Changes", comment: "Title for action to discard adding credentials.")
        let discardAction = UIAlertAction(title: discardActionTitle, style: .destructive) { _ in
            self.closeTinkLink()
        }
        alert.addAction(discardAction)

        let continueActionTitle = NSLocalizedString("AddCredentials.Discard.ContinueAction", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Continue Editing", comment: "Title for action to continue adding credentials.")
        let continueAction = UIAlertAction(title: continueActionTitle, style: .cancel)
        alert.addAction(continueAction)

        present(alert, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
@available(iOS 13.0, *)
extension TinkLinkViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDiscardActionSheet()
    }

    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        completion(result ?? .failure(.userCancelled))
    }

    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !didShowAddCredentialForm
    }
}
