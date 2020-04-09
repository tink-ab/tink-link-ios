import UIKit

protocol TextFieldTableViewCellDelegate: AnyObject {
    func textFieldTableViewCell(_ cell: TextFieldTableViewCell, willChangeToText text: String)
    func textFieldTableViewCellDidEndEditing(_ cell: TextFieldTableViewCell)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    weak var delegate: TextFieldTableViewCellDelegate?

    static var reuseIdentifier: String {
        return "TextFieldCell"
    }

    lazy var textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        setup()
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    private func setup() {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        delegate?.textFieldTableViewCell(self, willChangeToText: text)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldTableViewCellDidEndEditing(self)
    }
}
