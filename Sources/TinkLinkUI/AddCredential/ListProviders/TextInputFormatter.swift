import UIKit

final class TextInputFormatter: InputFormatter {
    let textField: UITextField

    required init(textField: UITextField) {
        self.textField = textField
    }

    func format(text: String) {  }
}
