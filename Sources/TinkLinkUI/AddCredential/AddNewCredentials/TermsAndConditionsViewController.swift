import UIKit
import WebKit

final class TermsAndConditionsViewController: UIViewController {

    private var webView: WKWebView { view as! WKWebView }

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Terms & Conditions"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        let url = URL(string: "https://link.tink.com/terms-and-conditions")!
        let request = URLRequest(url: url)

        webView.uiDelegate = self
        webView.navigationDelegate = self

        webView.load(request)
    }
}

extension TermsAndConditionsViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        dismiss(animated: true)
    }
}

extension TermsAndConditionsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setupCloseButtonHandler()
    }
}

extension TermsAndConditionsViewController {
    private func setupCloseButtonHandler() {
        let js = """
            document.querySelector("button").addEventListener("click", function() { window.close() }, null);
            """
        webView.evaluateJavaScript(js)
    }
}
