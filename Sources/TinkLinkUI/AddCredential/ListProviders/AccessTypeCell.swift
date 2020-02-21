import UIKit
import Kingfisher

class AccessTypeCell: UITableViewCell, ReusableCell {
    private let cardView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let button = FloatingButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let iconSize: CGFloat = 40
    private let iconTitleSpacing: CGFloat = 16

    private func setup() {
        selectionStyle = .none

        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        contentView.layer.shadowRadius = 15
        contentView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08

        cardView.layer.cornerRadius = 15
        cardView.backgroundColor = Color.secondaryGroupedBackground
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.clipsToBounds = true
        if #available(iOS 13.0, *) {
            cardView.layer.cornerCurve = .continuous
        }

        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(detailLabel)
        cardView.addSubview(button)

        contentView.layoutMargins = .init(top: 12, left: 20, bottom: 12, right: 20)

        cardView.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Font.semibold(.hecto)
        titleLabel.textColor = Color.label

        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = Font.regular(.deci)
        detailLabel.textColor = Color.label

        button.translatesAutoresizingMaskIntoConstraints = false
        button.text = "Add"
        button.minimumWidth = 125
        button.textColor = Color.secondaryGroupedBackground

        separatorInset.left = layoutMargins.left + iconSize + iconTitleSpacing
        separatorInset.right = layoutMargins.right

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            cardView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            cardView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),

            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.topAnchor.constraint(equalTo: cardView.layoutMarginsGuide.topAnchor),
            iconView.leadingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -iconTitleSpacing),

            titleLabel.topAnchor.constraint(equalTo: cardView.layoutMarginsGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.trailingAnchor),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor, constant: 8),
            detailLabel.trailingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.trailingAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            button.trailingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.trailingAnchor),
            button.topAnchor.constraint(equalTo: detailLabel.lastBaselineAnchor, constant: 24),
            button.bottomAnchor.constraint(equalTo: cardView.layoutMarginsGuide.bottomAnchor)

        ])
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let applyHighlight = {
            self.cardView.backgroundColor = highlighted ? Color.accentBackground : Color.background
        }

        if animated {
            UIView.animate(withDuration: 0.15) {
                applyHighlight()
            }
        } else {
            applyHighlight()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        detailLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.layer.cornerRadius = button.bounds.height / 2
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        separatorInset.left = layoutMargins.left + iconSize + iconTitleSpacing
    }

    func setImage(url: URL) {
        iconView.kf.setImage(with: ImageResource(downloadURL: url))
    }

    func setTitle(text: String) {
        titleLabel.text = text
    }

    func setDetail(text: String) {
        detailLabel.text = text
    }

}
