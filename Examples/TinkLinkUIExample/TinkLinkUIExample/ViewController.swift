import UIKit
import TinkLinkSDK
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
        let scope = TinkLink.Scope(scopes: [
            TinkLink.Scope.Statistics.read,
            TinkLink.Scope.Transactions.read,
            TinkLink.Scope.Categories.read,
            TinkLink.Scope.Accounts.read
        ])
        present(TinkLinkViewController(market: "SE", scope: scope), animated: true)
    }
}
