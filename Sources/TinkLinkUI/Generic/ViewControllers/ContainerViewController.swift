import UIKit

final class ContainerViewController: UIViewController {

    private var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setViewController(_ viewController: UIViewController) {
        if let currentViewController = currentViewController {
            currentViewController.view.removeFromSuperview()
            currentViewController.didMove(toParent: nil)
            self.currentViewController = nil
        }

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        currentViewController = viewController
    }
}
