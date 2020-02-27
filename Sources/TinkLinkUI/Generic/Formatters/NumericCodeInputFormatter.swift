import UIKit

final class NumericCodeInputFormatter: InputFormatter {
    private var numberFormatter = NumberFormatter()

    weak var textField: UITextField?

    required init(textField: UITextField) {
        self.textField = textField
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func format(text: String) {

        guard let textField = textField else {
            return
        }
        
        if text.isEmpty {
            return
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
