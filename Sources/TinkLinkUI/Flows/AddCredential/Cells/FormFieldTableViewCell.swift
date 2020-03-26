import UIKit
import TinkLink

protocol FormFieldTableViewCellDelegate: AnyObject {
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool
    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String)
    func formFieldCellDidEndEditing(_ cell: FormFieldTableViewCell)
}

class FormFieldTableViewCell: UITableViewCell, ReusableCell {
    weak var delegate: FormFieldTableViewCellDelegate?

    private var field: Form.Field?

    let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.regular(.nano)
        label.textColor = Color.secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    lazy var textField = FloatingPlaceholderTextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool { true }
    
    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tintColor = Color.accent
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.delegate = self

        footerLabel.font = Font.regular(.nano)

        contentView.layoutMargins = .init(top: 20, left: 20, bottom: 0, right: 20)
        contentView.backgroundColor = Color.background
        contentView.addSubview(textField)
        contentView.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: footerLabel.topAnchor, constant: -8),
            footerLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }

    func configure(with field: Form.Field) {
        self.field = field
        textField.configure(with: field)
        footerLabel.text = field.attributes.helpText
        footerLabel.textColor = Color.secondaryLabel
    }

    func setError(with errorText: String?) {
        if let errorText = errorText {
            footerLabel.text = errorText
            footerLabel.textColor = Color.warning
        } else {
            footerLabel.text = field?.attributes.helpText
            footerLabel.textColor = Color.secondaryLabel
        }
    }
}

extension FormFieldTableViewCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return false }

        let maxLength = field?.validationRules.maxLength ?? .max
        guard text.count <= maxLength else {
            return false
        }
        delegate?.formFieldCell(self, willChangeToText: text)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.formFieldCellDidEndEditing(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.formFieldCellShouldReturn(self) ?? true
    }
}

extension FloatingPlaceholderTextField {
    func configure(with field: Form.Field) {
        switch field.attributes.inputType {
        case .default:
            inputType = .text
        case .numeric:
            inputType = .number
        }

        if field.attributes.isEditable {
            isEnabled = true
            textFieldBackgroundColor = nil
            textAlignment = .natural
            lineWidth = 1.0
        } else {
            isEnabled = false
            textFieldBackgroundColor = Color.accentBackground
            textAlignment = .center
            lineWidth = 0.0
        }

        text = field.text
        placeholder = field.attributes.description
        isSecureTextEntry = field.attributes.isSecureTextEntry
    }
}
