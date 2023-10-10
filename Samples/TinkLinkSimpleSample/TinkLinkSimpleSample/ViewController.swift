import UIKit
import TinkLink

class ViewController: UIViewController {
    
    // This is a simple sample app, demonstrating how easy it can be to integrate Tinks mobile SDK in your app.

    // First, add your client ID. It can be found on console.tink.com in your apps settings.
    let clientID: String = <#String#>
    // Second, add `tinksdk://example` into the list of redirect URIs under your app's settings in Console.
    let redirectURI: String = "tinksdk://example"
    // Then specify the code for the market you want to test, e.g. "GB" for Great Britain, or "SE" for Sweden.
    let market = Market(code: <#String#>)
    // And lastly, define the BaseDomain. It determines the API base domain for Tink Link.
    let baseDomain: BaseDomain = .eu

    // Now you're all set!
    // Hit Run to test your project with Tinks mobile SDK.
    
    @IBAction func onTransactionsOneTimeAccessTap() {
        let configuration = Configuration(clientID: clientID, redirectURI: redirectURI, baseDomain: baseDomain)
        let controller = Tink.Transactions.connectAccountsForOneTimeAccess(configuration: configuration, market: market) { [weak self] result in
            self?.presentedViewController?.dismiss(animated: true)
            switch result {
            case .success(let connection):
                print("TinkLink OneTimeConnection code: \(String(describing: connection.code)), TinkLink OneTimeConnection credentialsID: \(connection.credentialsID)")
            case .failure(let error):
                print("TinkLink OneTimeConnection error: \(error)")
            }
        }
        self.present(controller, animated: true)
    }
}
