import UIKit

public final class NumberInputFormatter: InputFormatter {
    private var numberFormatter = NumberFormatter()
    private var maxDigits: Int?

    let textField: UITextField

    public init(textField: UITextField, maxDigits: Int? = nil) {
        self.textField = textField
        self.maxDigits = maxDigits
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    required public init(textField: UITextField) {
        self.textField = textField

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func format(text: String) {
        var text = text

        if text.isEmpty {
            return
        }

        if let maxDigits = maxDigits {
            text = String(text.prefix(maxDigits))
        }

        var index = (text as NSString).range(of: numberFormatter.decimalSeparator).location
        if index == NSNotFound {
            index = (text as NSString).length
        }

        let attributedString = NSMutableAttributedString(string: text)

        stride(from: index - 3, to: 0, by: -3).forEach { i in
            attributedString.addAttributes([.kern: 6.0], range: NSRange(location: i - 1, length: 1))
        }

        let location = textField.selectedTextRange
        textField.attributedText = attributedString
        textField.selectedTextRange = location
    }

    @objc
    func textFieldDidChange(_ sender: Any) {
        update()
    }
}
