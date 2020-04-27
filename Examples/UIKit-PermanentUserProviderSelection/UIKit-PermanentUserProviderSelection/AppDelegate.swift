import TinkLink
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = try! Tink.Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: URL(string: "link-demo://tink")!, environment: .production)
        Tink.configure(with: configuration)
        window = UIWindow(frame: UIScreen.main.bounds)
        let credentialsViewController = CredentialsViewController(style: .grouped)
        let navigationController = UINavigationController(rootViewController: credentialsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Tink.shared.open(url)
    }
}
