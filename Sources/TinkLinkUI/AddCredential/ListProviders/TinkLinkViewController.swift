import UIKit
import TinkLinkSDK

public class TinkLinkViewController: UINavigationController {
    private let tinkLink: TinkLink
    private let market: Market
    public let scope: TinkLink.Scope

    private lazy var userController = UserController(tinkLink: tinkLink)
    private lazy var providerController = ProviderController(tinkLink: tinkLink)
    private lazy var credentialController = CredentialController(tinkLink: tinkLink)
    private lazy var authorizationController = AuthorizationController(tinkLink: tinkLink)

    private var user: User?

    public init(tinkLink: TinkLink = .shared, market: Market, scope: TinkLink.Scope) {
        self.tinkLink = tinkLink
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

        userController.createTemporaryUser(for: market) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let user = try result.get()
                    self.user = user
                    self.providerController.user = user
                    self.credentialController.user = user
                    self.authorizationController.user = user
                    let providerListViewController = ProviderListViewController(providerController: self.providerController)
                    providerListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancel))
                    providerListViewController.addCredentialNavigator = self
                    self.setViewControllers([providerListViewController], animated: false)
                } catch {
                    // TODO: Error handling
                }
            }
        }
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
        dismiss(animated: true)
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
        let addCredentialViewController = AddCredentialViewController(provider: provider, userProfile: user?.userProfile, credentialController: credentialController)
        addCredentialViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        addCredentialViewController.addCredentialNavigator = self
        show(addCredentialViewController, sender: nil)
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
}
