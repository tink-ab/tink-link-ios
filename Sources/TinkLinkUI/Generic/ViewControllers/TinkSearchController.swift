import UIKit

final class TinkSearchController: UISearchController {
    private lazy var tinkSearchBar = TinkSearchBar()

    override var searchBar: UISearchBar { tinkSearchBar }
}

private final class TinkSearchBar: UISearchBar {
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
                self.textField?.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: Color.secondaryLabel, .font: Font.body])
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
        if #available(iOS 13.0, *) {
            let attributes = [
                NSAttributedString.Key.foregroundColor: Color.accent,
                NSAttributedString.Key.font: Font.body
            ]
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [TinkSearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        } else {
            tintColor = Color.accent
        }

        if let imageView = textField?.leftView as? UIImageView {
            imageView.tintColor = Color.secondaryLabel
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
        textField?.backgroundColor = Color.accentBackground
        textField?.textColor = Color.navigationBarLabel
        textField?.font = Font.body
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textField?.textColor = Color.navigationBarLabel
    }
}
