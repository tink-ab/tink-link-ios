import UIKit
import TinkLink

public class TinkLinkViewController: UINavigationController {
    private let tink: Tink
    private let market: Market
    public let scopes: [Scope]

    private var userController: UserController
    private var providerController: ProviderController
    private lazy var credentialController = CredentialController(tink: tink)
    private lazy var authorizationController = AuthorizationController(tink: tink)
    private lazy var addCredentialSession = AddCredentialSession(credentialController: self.credentialController, authorizationController: self.authorizationController, scopes: scopes, parentViewController: self)
    private lazy var providerPickerCoordinator = ProviderPickerCoordinator(parentViewController: self, providerController: providerController)
    private lazy var loadingViewController = LoadingViewController(providerController: providerController)

    private var clientDescription: ClientDescription?
    private let clientDescriptorLoadingGroup = DispatchGroup()
    private var error: Error?
    private let completion: (Result<AuthorizationCode, TinkLinkError>) -> Void

    public init(tink: Tink = .shared, market: Market, scopes: [Scope], providerKinds: Set<Provider.Kind> = .defaultKinds, authorization completion: @escaping (Result<AuthorizationCode, TinkLinkError>) -> Void) {
        self.tink = tink
        self.market = market
        self.scopes = scopes
        self.userController = UserController(tink: tink)
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
        userController.createTemporaryUser(for: market) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let user = try result.get()
                    self.providerController.user = user
                    self.credentialController.user = user
                    self.authorizationController.user = user

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
        let tinkLinkError = error.flatMap { TinkLinkError(error: $0) } ?? .userCancelled
        completion(.failure(tinkLinkError))
        dismiss(animated: true)
    }
}

// MARK: - Alerts

extension TinkLinkViewController {

    private func showCreateTemporaryUserAlert(for error: Error) {
        let localizedError = error as? LocalizedError

        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "The service is unavailable at the moment.",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )
        loadingViewController.hideLoadingIndicator()
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            self.loadingViewController.showLoadingIndicator()
            self.setViewControllers([self.loadingViewController], animated: false)
            self.start()
        }
        alertController.addAction(retryAction)

        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    private func showUnknownAggregatorAlert(for error: Error) {
        let localizedError = error as? LocalizedError

        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "The service is unavailable at the moment.",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    private func showDownloadPrompt(for thirdPartyAppAuthenticationError: ThirdPartyAppAuthenticationTask.Error) {
        let alertController = UIAlertController(title: thirdPartyAppAuthenticationError.errorDescription, message: thirdPartyAppAuthenticationError.failureReason, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthenticationError.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
                UIApplication.shared.open(appStoreURL)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default)
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
            title = "Error"
            message = error.localizedDescription
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
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
        let addCredentialViewController = AddCredentialViewController(provider: provider, credentialController: credentialController, clientName: clientDescription.name, isAggregator: clientDescription.isAggregator)
        addCredentialViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        addCredentialViewController.delegate = self
        if viewControllers.last is LoadingViewController {
            replaceTopViewController(with: addCredentialViewController, animated: true)
        } else {
            show(addCredentialViewController, sender: nil)
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
        let viewController = CredentialSuccessfullyAddedViewController(companyName: clientDescription.name) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
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
        self.error = error
        loadingViewController.update(error)
    }
}

// MARK: - AddCredentialViewControllerDelegate

extension TinkLinkViewController: AddCredentialViewControllerDelegate {
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

    func addCredential(provider: Provider, form: Form, allowAnotherDevice: Bool) {
        addCredentialSession.addCredential(provider: provider, form: form, allowAnotherDevice: allowAnotherDevice) { [weak self] result in
            do {
                let authorizationCode = try result.get()
                self?.completion(.success(authorizationCode))
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
        viewControllers.contains(where: { $0 is AddCredentialViewController })
    }

    private var didShowCredentialSuccessfullyAdded: Bool {
        viewControllers.contains(where: { $0 is CredentialSuccessfullyAddedViewController })
    }

    private func showDiscardActionSheet() {
        let alert = UIAlertController(title: "Are you sure you want to discard this new credential?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: { _ in
            self.closeTinkLink()
        }))
        alert.addAction(UIAlertAction(title: "Continue Editing", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
@available(iOS 13.0, *)
extension TinkLinkViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDiscardActionSheet()
    }

    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if !didShowCredentialSuccessfullyAdded {
            let tinkLinkError = error.flatMap { TinkLinkError(error: $0) } ?? .userCancelled
            completion(.failure(tinkLinkError))
        }
        return !didShowAddCredentialForm
    }
}
