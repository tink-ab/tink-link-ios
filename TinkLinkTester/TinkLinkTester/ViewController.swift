import UIKit
import TinkLink
import TinkLinkUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let label = UILabel()
        label.text = "Aggregation\n SDK sample app"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(showTinkLink), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitle("Start aggregation flow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
        button.backgroundColor = UIColor(red: 66.0 / 255.0, green: 119.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
        button.layer.cornerRadius = 24

        view.addSubview(label)
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            button.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -48)
        ])
        
    }

    @objc private func showTinkLink() {
        let scopes: [Scope] = [
            .statistics(.read),
            .transactions(.read),
            .categories(.read),
            .accounts(.read)
        ]

        let tinkLinkViewController = TinkLinkViewController(market: "SE", scopes: scopes) { _ in }
        present(tinkLinkViewController, animated: true)
    }

    @objc func showTinkLinkWithAuthrorizationCode() {
        let authorizationCode = "YOUR_AUTHORIZATION_CODE"

        let tinkLinkViewController = TinkLinkViewController(authorizationCode: AuthorizationCode(authorizationCode)) { _ in }
        present(tinkLinkViewController, animated: true)
    }

    @objc private func showTinkLinkWithUserSession() {
        let accessToken = "YOUR_ACCESS_TOKEN"

        let tinkLinkViewController = TinkLinkViewController(userSession: .accessToken(accessToken)) { _ in }
        present(tinkLinkViewController, animated: true)
    }
}

