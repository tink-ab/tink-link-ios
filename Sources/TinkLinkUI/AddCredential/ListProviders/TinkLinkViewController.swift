import UIKit
import TinkLink

public class TinkLinkViewController: UINavigationController {
    private let tink: Tink
    private let market: Market
    public let scope: Tink.Scope

    private lazy var userController = UserController(tink: tink)
    private lazy var providerController = ProviderController(tink: tink)
    private lazy var credentialController = CredentialController(tink: tink)
    private lazy var authorizationController = AuthorizationController(tink: tink)

    private var isAggregator: Bool?
    private let isAggregatorLoadingGroup = DispatchGroup()

    public init(tink: Tink = .shared, market: Market, scope: Tink.Scope) {
        self.tink = tink
        self.market = market
        self.scope = scope

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()

        view.backgroundColor = Color.background
        let loadingViewController = LoadingViewController()
        loadingViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        setViewControllers([loadingViewController], animated: false)

        presentationController?.delegate = self

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

                    let providerListViewController = ProviderListViewController(providerController: self.providerController)
                    providerListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancel))
                    providerListViewController.addCredentialNavigator = self
                    self.setViewControllers([providerListViewController], animated: false)

                    self.isAggregatorLoadingGroup.enter()
                    self.authorizationController.isAggregator { (aggregatorResult) in
                        DispatchQueue.main.async {
                            do {
                                self.isAggregator = try aggregatorResult.get()
                                self.isAggregatorLoadingGroup.leave()
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

    private func showCreateTemporaryUserAlert(for error: Error) {
        let localizedError = error as? LocalizedError

        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "The service is unavailable at the moment.",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            let loadingViewController = LoadingViewController()
            loadingViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancel))
            self.setViewControllers([loadingViewController], animated: false)
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

    private func setupNavigationBarAppearance() {
        navigationBar.tintColor = Color.accent
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.buttonAppearance.normal.titleTextAttributes = [
                .font: Font.regular(.deci)
            ]
            appearance.buttonAppearance.highlighted.titleTextAttributes = [
                .font: Font.regular(.deci)
            ]

            appearance.titleTextAttributes = [
                .font: Font.bold(.hecto),
                .foregroundColor: Color.label
            ]

            appearance.backgroundColor = Color.background

            navigationBar.standardAppearance = appearance
            navigationBar.isTranslucent = false
        } else {

            // Bar Button Item
            let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [TinkLinkViewController.self])
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.regular(.deci)
                ], for: .normal)
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.regular(.deci)
                ], for: .highlighted)

            navigationBar.titleTextAttributes = [
                .font: Font.bold(.hecto),
                .foregroundColor: Color.label
            ]

            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = Color.background
            navigationBar.isTranslucent = false
        }
    }

    @objc func cancel() {
        if didShowAddCredentialForm {
            showDiscardActionSheet()
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - AddCredentialFlowNavigating

extension TinkLinkViewController: AddCredentialFlowNavigating {

    private func setupNavigationItem(for viewController: UIViewController, title: String?) {
        viewController.title = title
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    private func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        var newViewControllers = viewControllers
        _ = newViewControllers.popLast()
        newViewControllers.append(viewController)
        setViewControllers(newViewControllers, animated: animated)
    }

    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        let viewController = FinancialInstitutionPickerViewController(financialInstitutionNodes: financialInstitutionNodes)
        setupNavigationItem(for: viewController, title: title)
        viewController.addCredentialNavigator = self
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController(accessTypeNodes: accessTypeNodes)
        setupNavigationItem(for: viewController, title: title)
        viewController.addCredentialNavigator = self
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?) {
        let viewController = CredentialKindPickerViewController(credentialKindNodes: credentialKindNodes)
        setupNavigationItem(for: viewController, title: title)
        viewController.addCredentialNavigator = self
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        guard let isAggregator = isAggregator else {
            isAggregatorLoadingGroup.notify(queue: .main) { [weak self] in
                self?.showAddCredential(for: provider)
            }
            show(LoadingViewController(), sender: nil)
            return
        }
        let addCredentialViewController = AddCredentialViewController(provider: provider, credentialController: credentialController, isAggregator: isAggregator)
        addCredentialViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        addCredentialViewController.addCredentialNavigator = self
        if viewControllers.last is LoadingViewController {
            replaceTopViewController(with: addCredentialViewController, animated: true)
        } else {
            show(addCredentialViewController, sender: nil)
        }
    }

    func showScopeDescriptions() {
        let viewController = ScopeDescriptionListViewController(authorizationController: authorizationController, scope: scope)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeMoreInfo))
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    func showWebContent(with url: URL) {
        let viewController = LegalViewController(url: url)
        present(viewController, animated: true)
    }

    func showAddCredentialSuccess() {
        //TODO: Get proper company name
        let viewController = CredentialSuccessfullyAddedViewController(companyName: "Test")
        show(viewController, sender: self)
    }
}

// MARK: - Helpers
extension TinkLinkViewController {
    private var didShowAddCredentialForm: Bool {
        viewControllers.contains(where: { $0 is AddCredentialViewController })
    }

    private func showDiscardActionSheet() {
        let alert = UIAlertController(title: "Are you sure you want to discard this new credential?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: { _ in
            self.dismiss(animated: true)
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
        return !didShowAddCredentialForm
    }
}
