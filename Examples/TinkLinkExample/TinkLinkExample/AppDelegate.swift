import TinkLink
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = TinkLinkConfiguration(
            clientID: ProcessInfo.processInfo.environment["TINK_LINK_EXAMPLE_CLIENT_ID"] ?? "YOUR_CLIENT_ID",
            appURI: URL(string: ProcessInfo.processInfo.environment["TINK_LINK_EXAMPLE_REDIRECT_URI"] ?? "tinklink://example")!
        )

        Tink.configure(with: configuration)
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Tink.shared.open(url)
    }
}
