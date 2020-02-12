import UIKit
import TinkLinkSDK

public class TinkLinkViewController: UINavigationController {
    private let userController = UserController()
    private let providerController = ProviderController()
    private let credentialController = CredentialController()

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = Color.accent
        view.backgroundColor = Color.background

        userController.createTemporaryUser(for: .init(code: "SE")) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let user = try result.get()
                    self.providerController.user = user
                    self.credentialController.user = user
                    let providerListViewController = ProviderListViewController(providerController: self.providerController)
                    providerListViewController.addCredentialNavigator = self
                    self.setViewControllers([providerListViewController], animated: false)
                } catch {
                    // TODO: Error handling
                }
            }
        }
    }
}

// MARK: - AddCredentialFlowNavigating

extension TinkLinkViewController: AddCredentialFlowNavigating {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        let viewController = FinancialInstitutionPickerViewController(credentialController: credentialController)
        viewController.title = title
        viewController.financialInstitutionNodes = financialInstitutionNodes
        viewController.addCredentialNavigator = self
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController(credentialController: credentialController)
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        viewController.addCredentialNavigator = self
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?) {
        let viewController = CredentialKindPickerViewController(credentialController: credentialController)
        viewController.title = title
        viewController.credentialKindNodes = credentialKindNodes
        viewController.addCredentialNavigator = self
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider, credentialController: credentialController)
        show(addCredentialViewController, sender: nil)
    }
}
