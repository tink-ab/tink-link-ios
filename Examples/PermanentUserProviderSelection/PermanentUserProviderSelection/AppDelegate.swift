import TinkLink
import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private lazy var credentialsController = CredentialsController()
    private lazy var providerController = ProviderController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = try! Tink.Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: URL(string: "link-demo://tink")!)
        Tink.configure(with: configuration)
        Tink.shared.setCredential(.accessToken("YOUR_ACCESS_TOKEN"))
        let contentView = ContentView()
            .environmentObject(credentialsController)
            .environmentObject(providerController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()

        return true
    }
}

