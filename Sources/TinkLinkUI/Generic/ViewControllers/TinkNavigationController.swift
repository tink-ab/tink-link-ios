import UIKit

class TinkNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background
        view.tintColor = Color.accent
        setupNavigationBarAppearance()
    }
}
