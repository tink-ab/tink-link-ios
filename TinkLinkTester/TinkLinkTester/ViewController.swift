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
        let scopes: [Scope] = [
            .statistics(.read),
            .transactions(.read),
            .categories(.read),
            .accounts(.read)
        ]

        let tinkLinkViewController = TinkLinkViewController(market: "SE", scopes: scopes, providerKinds: .all) { _ in }
        present(tinkLinkViewController, animated: true)
    }
}

