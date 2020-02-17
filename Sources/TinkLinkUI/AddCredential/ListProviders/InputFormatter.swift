import UIKit

protocol InputFormatter {
    var textField: UITextField? { get }
    init(textField: UITextField)

    func update()
    func format(text: String)
}

extension InputFormatter {
    func update() {
        format(text: textField?.text ?? "")
    }
}
