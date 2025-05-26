import UIKit

/// Domain:
/// EU: link.tink.com
/// US: link.visa.com
let linkDomain: String = <#DOMAIN#>

let yourClientID: String = <#YOUR_CLIENT_ID#>
let yourPaymentRequestID: String = <#YOUR_PAYMENT_REQUEST_ID#>
let yourRedirectURI: String = <#YOUR_REDIRECT_URI#>
let yourCallbackURI: String = <#YOUR_CALLBACK_URI#>
/// Your credentials.

var demoUrl: URL = {
    URL(string:
    """
    https://\(linkDomain)/1.0/pay/direct?client_id=\(yourClientID)&market=SE&locale=en_US&payment_request_id=\(yourPaymentRequestID)&redirect_uri=\(yourRedirectURI)&app_uri=\(yourCallbackURI)&auto_redirect_mobile=true
    """
    )!
}()

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = UIButton.Configuration.gray()
        let action = UIAction(title: "Launch Tink Link") { [weak self] action in
            guard let self else { return assertionFailure("Unable to present") }
            
            let tinkViewController = LinkViewController(url: demoUrl)
            self.show(tinkViewController, sender: nil)
        }
        let button = UIButton(configuration: configuration, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

