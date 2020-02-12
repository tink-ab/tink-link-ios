import UIKit

public class TinkLinkViewController: UINavigationController {
    private let userController = UserController()
    private let providerController = ProviderController()
    private let credentialController = CredentialController()

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
                    let providerListViewController = ProviderListViewController(providerController: self.providerController, credentialController: self.credentialController)
                    self.setViewControllers([providerListViewController], animated: false)
                } catch {
                    // TODO: Error handling
                }
            }
        }



    }
}
