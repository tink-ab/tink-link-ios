import UIKit

public final class TextInputFormatter: InputFormatter {
    let textField: UITextField

    required public init(textField: UITextField) {
        self.textField = textField
    }

    func format(text: String) {  }
}
