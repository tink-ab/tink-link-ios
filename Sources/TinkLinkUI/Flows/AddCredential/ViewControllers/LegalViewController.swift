import UIKit
import WebKit

final class LegalViewController: UIViewController {
    private var webView: WKWebView { view as! WKWebView }
    private lazy var activityIndicator = ActivityIndicatorView()

    private let url: URL

    private var retryDelay: TimeInterval = 0.5

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        view.addSubview(activityIndicator)
        activityIndicator.tintColor = Color.accent
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        let request = URLRequest(url: url)

        webView.uiDelegate = self
        webView.navigationDelegate = self

        activityIndicator.startAnimating()
        webView.load(request)
    }
}

extension LegalViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        dismiss(animated: true)
    }
}

extension LegalViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        setupCloseButtonHandler()
    }
}

extension LegalViewController {
    private func setupCloseButtonHandler() {
        let js = """
        document.querySelector("button").addEventListener("click", function() { window.close() }, null);
        """
        webView.evaluateJavaScript(js, completionHandler: { [weak self, retryDelay] a, error in
            if case WKError.javaScriptExceptionOccurred? = error {
                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                    self?.setupCloseButtonHandler()
                }
            }
        })

        retryDelay *= 2
    }
}
