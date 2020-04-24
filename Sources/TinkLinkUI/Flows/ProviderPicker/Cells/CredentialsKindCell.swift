import UIKit

class CredentialsKindCell: UITableViewCell, ReusableCell {
    private let iconBackgroundView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let iconBackgroundSize: CGFloat = 40
    private let iconSize: CGFloat = 24
    private let iconTitleSpacing: CGFloat = 24

    private func setup() {
        selectionStyle = .none

        backgroundColor = .clear
        contentView.backgroundColor = Color.background

        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)

        contentView.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)

        iconBackgroundView.backgroundColor = Color.accent
        iconBackgroundView.clipsToBounds = true
        iconBackgroundView.layer.cornerRadius = iconBackgroundSize / 2
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Color.background
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Font.body
        titleLabel.textColor = Color.label

        separatorInset.left = layoutMargins.left + iconSize + iconTitleSpacing
        separatorInset.right = layoutMargins.right

        NSLayoutConstraint.activate([
            iconBackgroundView.widthAnchor.constraint(equalToConstant: iconBackgroundSize),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: iconBackgroundSize),
            iconBackgroundView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconBackgroundView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),

            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -iconTitleSpacing),

            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.lastBaselineAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        separatorInset.left = layoutMargins.left + iconSize + iconTitleSpacing
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        let applyHighlight = {
            self.contentView.backgroundColor = highlighted ? Color.accentBackground : Color.background
        }

        if animated {
            UIView.animate(withDuration: 0.15) {
                applyHighlight()
            }
        } else {
            applyHighlight()
        }
    }

    func setIcon(_ icon: Icon) {
        iconView.image = UIImage(icon: icon)?.withRenderingMode(.alwaysTemplate)
    }

    func setTitle(text: String) {
        titleLabel.text = text
    }
}
