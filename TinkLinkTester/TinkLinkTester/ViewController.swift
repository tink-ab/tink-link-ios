import UIKit
import TinkLink
import TinkLinkUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(showTinkLink), for: .touchUpInside)
        button.setTitle("Start TinkLink", for: .normal)
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }

    @objc private func showTinkLink() {
        let scope = Tink.Scope(scopes: [
            Tink.Scope.Statistics.read,
            Tink.Scope.Transactions.read,
            Tink.Scope.Categories.read,
            Tink.Scope.Accounts.read
        ])

        let tinkLinkViewController = TinkLinkViewController(market: "SE", scope: scope, providerKinds: .all) { _ in }
        present(tinkLinkViewController, animated: true)
    }
}

