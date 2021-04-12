import UIKit
import Kingfisher

class ProviderCell: UITableViewCell, ReusableCell {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let betaLabel = ProviderTagView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let iconSize: CGFloat = 40
    private let iconTitleSpacing: CGFloat = 16

    private var trailingTitleConstraint: NSLayoutConstraint!
    private var trailingBetaConstraint: NSLayoutConstraint!

    private func setup() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = Color.background

        contentView.addSubview(iconView)

        contentView.layoutMargins = .init(top: 32, left: 24, bottom: 32, right: 24)

        iconView.contentMode = .scaleAspectFit

        contentView.addSubview(titleLabel)
        contentView.addSubview(betaLabel)
        contentView.addSubview(descriptionLabel)

        titleLabel.numberOfLines = 0
        titleLabel.font = Font.body1
        titleLabel.textColor = Color.label

        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = Font.body2
        descriptionLabel.textColor = Color.secondaryLabel

        betaLabel.isHidden = true

        separatorInset.left = contentView.layoutMargins.left + iconSize + iconTitleSpacing
        separatorInset.right = contentView.layoutMargins.right

        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        betaLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        trailingTitleConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor)
        trailingBetaConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: betaLabel.trailingAnchor)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: iconTitleSpacing),
            trailingTitleConstraint,

            betaLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            betaLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            descriptionLabel.lastBaselineAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        descriptionLabel.text = ""
        setBetaLabelHidden(true)
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        separatorInset.left = contentView.layoutMargins.left + iconSize + iconTitleSpacing
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        let applyHighlight = {
            self.backgroundColor = highlighted ? Color.accentBackground : Color.background
        }

        if animated {
            UIView.animate(withDuration: 0.15) {
                applyHighlight()
            }
        } else {
            applyHighlight()
        }
    }

    func setImage(url: URL) {
        iconView.kf.setImage(with: ImageResource(downloadURL: url))
    }

    func setTitle(text: String) {
        titleLabel.text = text
    }

    func setDescription(text: String) {
        descriptionLabel.text = text
    }

    func setBetaLabelHidden(_ hidden: Bool) {
        betaLabel.isHidden = hidden
        trailingTitleConstraint.isActive = hidden
        trailingBetaConstraint.isActive = !hidden
    }
}
