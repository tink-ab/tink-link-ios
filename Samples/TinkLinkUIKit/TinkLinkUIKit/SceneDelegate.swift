import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        if url.host == "open" {
            NotificationCenter.default.post(name: .linkOpen, object: nil, userInfo: ["url": url])
        }
        
        if url.host == "callback" {
            NotificationCenter.default.post(name: .linkCallback, object: nil, userInfo: ["url": url])
        }
    }
}
