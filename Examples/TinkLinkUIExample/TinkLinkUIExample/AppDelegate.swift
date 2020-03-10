import TinkLink
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = try! Tink.Configuration(clientID: "d781eeed156f4129a7784234858565d2", redirectURI: URL(string: "http://localhost:3000/callback")!, environment: .custom(grpcURL: URL(string: "https://main-grpc.staging.oxford.tink.se:443")!, restURL: URL(string: "https://api-gateway.staging.oxford.tink.se")!))


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
