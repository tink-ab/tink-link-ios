import UIKit

final class TextInputFormatter: InputFormatter {
    weak var textField: UITextField?

    required init(textField: UITextField) {
        self.textField = textField
    }

    func format(text: String) {  }
}
