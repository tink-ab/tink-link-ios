import TinkLink
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = TinkLinkConfiguration(
            clientID: "YOUR_CLIENT_ID",
            appURI: URL(string: "link-demo://tink")!
        )
        Tink.configure(with: configuration)

        Tink.shared.userSession = .accessToken("YOUR_ACCESS_TOKEN")

        window = UIWindow(frame: UIScreen.main.bounds)

        let credentialsViewController = CredentialsPickerViewController(style: .grouped)
        credentialsViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCredentials))
        credentialsViewController.toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Transfer", style: .plain, target: self, action: #selector(transfer)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]

        let navigationController = UINavigationController(rootViewController: credentialsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.isToolbarHidden = false

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Tink.shared.open(url)
    }
}

extension AppDelegate {
    @objc private func addCredentials(sender: UIBarButtonItem) {
        let providerListViewController = FinancialInstitutionGroupPickerViewController()
        providerListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddingCredentials))
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        navigationController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(navigationController, animated: true)
    }

    @objc private func cancelAddingCredentials(_ sender: Any) {
        window?.rootViewController?.dismiss(animated: true)
    }

    @objc private func transfer(_ sender: UIBarButtonItem) {
        let transferViewController = TransferViewController()
        let navigationController = UINavigationController(rootViewController: transferViewController)
        window?.rootViewController?.present(navigationController, animated: true)
    }
}
