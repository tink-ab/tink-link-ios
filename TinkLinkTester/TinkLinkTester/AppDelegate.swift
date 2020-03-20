import UIKit
import TinkLink

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var environment: Environment {
            if let grpcURL = ProcessInfo.processInfo.environment["TINK_LINK_TESTER_GRPC_ENDPOINT"].flatMap(URL.init(string:)),
                let restURL = ProcessInfo.processInfo.environment["TINK_LINK_TESTER_REST_ENDPOINT"].flatMap(URL.init(string:)) {
                return .custom(grpcURL: grpcURL, restURL: restURL)
            } else {
                return .production
            }
        }
        let configuration = try! Tink.Configuration(
            clientID: ProcessInfo.processInfo.environment["TINK_LINK_TESTER_CLIENT_ID"]!,
            redirectURI: ProcessInfo.processInfo.environment["TINK_LINK_TESTER_REDIRECT_URI"].flatMap(URL.init(string:)) ?? URL(string: "link-demo://tink")!,
            environment: environment
        )

        Tink.configure(with: configuration)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()

        return true
    }
}

