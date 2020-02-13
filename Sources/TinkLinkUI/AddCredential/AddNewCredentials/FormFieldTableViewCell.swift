import UIKit
import TinkLinkSDK

protocol FormFieldTableViewCellDelegate: AnyObject {
    func textFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String)
    func textFieldCellDidEndEditing(_ cell: FormFieldTableViewCell)
}

class FormFieldTableViewCell: UITableViewCell {
    weak var delegate: FormFieldTableViewCellDelegate?

    static var reuseIdentifier: String { "TextFieldCell" }

    lazy var textField = FormFieldTextField()
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.regular(.hecto)
        label.textColor = Color.label
        return label
    }()
    let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.regular(.nano)
        label.textColor = Color.secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self

        contentView.layoutMargins = .init(top: 4, left: 20, bottom: 4, right: 20)
        contentView.addSubview(textField)
        contentView.addSubview(headerLabel)
        contentView.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            textField.topAnchor.constraint(equalTo: headerLabel.lastBaselineAnchor, constant: 12),
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: footerLabel.topAnchor, constant: -8),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            footerLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }

    func configure(field: Form.Field) {
        textField.configure(field: field)
        headerLabel.text = field.attributes.description
        footerLabel.text = field.attributes.helpText
    }
}

extension FormFieldTableViewCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        delegate?.textFieldCell(self, willChangeToText: text)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.accentBackground.cgColor
        delegate?.textFieldCellDidEndEditing(self)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.accent.cgColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return resignFirstResponder()
    }
}
