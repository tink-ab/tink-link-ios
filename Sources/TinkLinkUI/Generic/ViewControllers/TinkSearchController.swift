import UIKit

final class TinkSearchController: UISearchController {

    private lazy var tinkSearchBar = TinkSearchBar()

    override var searchBar: UISearchBar { tinkSearchBar }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let appearance = UITextField.appearance(whenContainedInInstancesOf: [TinkSearchBar.self])
        appearance.defaultTextAttributes = [.foregroundColor: Color.label, .font: Font.regular(.deci)]
    }
}

final private class TinkSearchBar: UISearchBar {

    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return subviews.first?.subviews.first { $0 is UITextField } as? UITextField
        }
    }

    override var placeholder: String? {
        didSet {
            // Hack: You need the async call here to have the color apply properly. 
            DispatchQueue.main.async {
                self.textField?.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: Color.secondaryLabel, .font: Font.regular(.deci)])
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        if let imageView = textField?.leftView as? UIImageView {
            imageView.tintColor = Color.secondaryLabel
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
        textField?.backgroundColor = Color.secondaryBackground
    }
}
