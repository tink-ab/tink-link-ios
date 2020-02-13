import UIKit

class TermsAndConditionsViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Terms & Conditions"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
    }
}
