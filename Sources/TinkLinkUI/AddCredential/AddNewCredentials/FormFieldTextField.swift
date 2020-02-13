import UIKit
import TinkLinkSDK

final class FormFieldTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        autocorrectionType = .no
        autocapitalizationType = .none
        layer.borderColor = Color.accentBackground.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 4.0
        textColor = Color.label
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }

    func configure(field: Form.Field) {
        placeholder = field.attributes.placeholder
        isSecureTextEntry = field.attributes.isSecureTextEntry
        isEnabled = field.attributes.isEditable

        if field.attributes.isEditable {
            text = field.text
            backgroundColor = .clear
            textAlignment = .left
            font = Font.regular(.hecto)
        } else {
            backgroundColor = Color.accentBackground
            textAlignment = .center
            attributedText = NSAttributedString(string: field.text, attributes: [.font: Font.regular(.mega), .kern: 6.0])
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 12, left: 20, bottom: 12, right: 20))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 12, left: 20, bottom: 12, right: 20))
    }
}

