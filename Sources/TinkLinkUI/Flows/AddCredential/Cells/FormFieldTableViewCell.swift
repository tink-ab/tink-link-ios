import UIKit
import TinkLink

protocol FormFieldTableViewCellDelegate: AnyObject {
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool
    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String)
    func formFieldCellDidEndEditing(_ cell: FormFieldTableViewCell)
}

class FormFieldTableViewCell: UITableViewCell, ReusableCell {

    struct ViewModel {
        enum InputType {
            case text, number
        }

        var text: String?
        var isEditable: Bool
        var placeholderText: String?
        var isSecureTextEntry: Bool
        var inputType: InputType
        var maxLength: Int?
        var helpText: String?
    }

    weak var delegate: FormFieldTableViewCellDelegate?

    private var viewModel: ViewModel?

    let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.regular(.micro)
        label.textColor = Color.secondaryLabel
        label.numberOfLines = 0
        label.setLineHeight(lineHeight: 20)
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

        contentView.layoutMargins = .init(top: 20, left: 24, bottom: 0, right: 24)
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

    func configure(with viewModel: ViewModel) {
        self.viewModel = viewModel
        textField.configure(with: viewModel)
        footerLabel.text = viewModel.helpText
        footerLabel.textColor = Color.secondaryLabel
        footerLabel.setLineHeight(lineHeight: 20)
    }

    func setError(with errorText: String?) {
        if let errorText = errorText {
            footerLabel.text = errorText
            footerLabel.textColor = Color.warning
        } else {
            footerLabel.text = viewModel?.helpText
            footerLabel.textColor = Color.secondaryLabel
        }
    }
}

extension FormFieldTableViewCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fieldText: String
        // If the textField is password and it has an initial value, then when begin to edit the textfield will clear the text, so need to also reset the form field text cache.
        if textField.isSecureTextEntry, !(viewModel?.text?.isEmpty ?? true) {
            viewModel?.text = String()
            fieldText = string
        } else if let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            fieldText = text
        } else {
            return false
        }

        let maxLength = viewModel?.maxLength ?? .max
        guard fieldText.count <= maxLength else {
            return false
        }

        delegate?.formFieldCell(self, willChangeToText: fieldText)
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
    func configure(with viewModel: FormFieldTableViewCell.ViewModel) {
        switch viewModel.inputType {
        case .text:
            inputType = .text
        case .number:
            inputType = .number
        }
        
        isEnabled = viewModel.isEditable
        text = viewModel.text
        placeholder = viewModel.placeholderText
        isSecureTextEntry = viewModel.isSecureTextEntry
    }
}

extension FormFieldTableViewCell.ViewModel {
    init(field: Form.Field) {
        let inputType: InputType
        switch field.attributes.inputType {
        case .default:
            inputType = .text
        case .numeric:
            inputType = .number
        }

        self.init(text: field.text, isEditable: field.attributes.isEditable, placeholderText: field.attributes.placeholder, isSecureTextEntry: field.attributes.isSecureTextEntry, inputType: inputType, maxLength: field.validationRules.maxLength, helpText: field.attributes.helpText)
    }
}
