import UIKit
@preconcurrency import WebKit
import SafariServices

final class LinkViewController: UIViewController {
    
    private let url: URL
    private let webView = WKWebView()
    private var safariViewController: SFSafariViewController?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .linkOpen, object: nil, queue: .main) { [weak self] notification in
            self?.safariViewController?.dismiss(animated: true)
            self?.safariViewController = nil
        }

        NotificationCenter.default.addObserver(forName: .linkCallback, object: nil, queue: .main) { [weak self] notification in
            guard let url = notification.userInfo?["url"] as? URL else { return assertionFailure("URL is not found") }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return assertionFailure("URL deos not contain components") }
            
            components.queryItems?.forEach({ item in
                print("RESPONSE QUERY ITEM: \(item.description)")
            })
            self?.dismiss(animated: true)
        }

        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        webView.load(URLRequest(url: url))
    }
}

extension LinkViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.host == self.url.host, navigationAction.targetFrame != nil {
                // Handle same page link.tink.com navigation in the web view
                decisionHandler(.allow)
            } else if ["http", "https"].contains(url.scheme) {
                // Attempt to open HTTP(s) navigation using universal links, otherwise present in embedded in-app browser
                UIApplication.shared.open(url, options: [.universalLinksOnly: true], completionHandler: { [weak self] success in
                    guard !success else { return }
                    
                    let safariViewController = SFSafariViewController(url: url)
                    safariViewController.modalPresentationStyle = .formSheet
                    self?.present(safariViewController, animated: true)
                    self?.safariViewController = safariViewController
                })
                decisionHandler(.cancel)
            } else {
                // Open custom scheme deep links (eg. bankid://) using the system handler
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
