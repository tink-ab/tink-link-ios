import UIKit
import TinkLinkSDK

public class TinkLinkViewController: UINavigationController {
    private let userController = UserController()
    private let providerController = ProviderController()
    private let credentialController = CredentialController()
    private let authorizationController = AuthorizationController()

    public let scope: TinkLink.Scope

    public init(scope: TinkLink.Scope) {
        self.scope = scope
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = Color.accent
        view.backgroundColor = Color.background
        setViewControllers([UIViewController()], animated: false)

        userController.createTemporaryUser(for: .init(code: "SE")) { [weak self] result in
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
                } catch {
                    // TODO: Error handling
                }
            }
        }
    }

    @objc func cancel() {
        dismiss(animated: true)
    }

    @objc private func closeMoreInfo(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @objc private func closeTermsAndConditions(_ sender: UIBarButtonItem) {
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
        let addCredentialViewController = AddCredentialViewController(provider: provider, credentialController: credentialController)
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

    func showTermsAndConditions() {
        let url = URL(string: "https://link.tink.com/terms-and-conditions")!
        let viewController = LegalViewController(url: url)
        present(viewController, animated: true)
    }
}
