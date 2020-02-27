import UIKit

final class NumericCodeInputFormatter: InputFormatter {
    private var numberFormatter = NumberFormatter()
    private var maxDigits: Int?

    weak var textField: UITextField?

    init(textField: UITextField, maxDigits: Int? = nil) {
        self.textField = textField
        self.maxDigits = maxDigits
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    required init(textField: UITextField) {
        self.textField = textField

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func format(text: String) {

        guard let textField = textField else {
            return
        }
        
        var text = text

        if text.isEmpty {
            return
        }

        if let maxDigits = maxDigits {
            text = String(text.prefix(maxDigits))
        }

        let attributedString = NSMutableAttributedString(string: text, attributes: [.kern: 6.0])

        let location = textField.selectedTextRange
        textField.attributedText = attributedString
        textField.selectedTextRange = location
    }

    @objc
    func textFieldDidChange(_ sender: Any) {
        update()
    }
}
