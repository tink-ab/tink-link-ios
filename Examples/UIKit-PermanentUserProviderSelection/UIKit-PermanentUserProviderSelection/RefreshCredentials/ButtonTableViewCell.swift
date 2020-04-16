import UIKit

class ButtonTableViewCell: UITableViewCell {
    let actionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        actionLabel.textAlignment = .center
        actionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        actionLabel.textColor = tintColor
        contentView.addSubview(actionLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        actionLabel.frame = contentView.bounds
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        actionLabel.textColor = tintColor
    }
}
