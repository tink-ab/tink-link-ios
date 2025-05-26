import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "open" {
            NotificationCenter.default.post(name: .linkOpen, object: nil, userInfo: ["url": url])
            return true
        }
        
        if url.host == "callback" {
            NotificationCenter.default.post(name: .linkCallback, object: nil, userInfo: ["url": url])
            return true
        }
        
        return false
    }
}

extension Notification.Name {
    static let linkCallback = Notification.Name("Link.Callback")
    static let linkOpen = Notification.Name("Link.Open")
}
