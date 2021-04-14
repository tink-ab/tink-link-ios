import UIKit

class CredentialsKindCell: UITableViewCell, ReusableCell {
    private let iconBackgroundView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let betaLabel = ProviderTagView()
    private let demoLabel = ProviderTagView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let iconBackgroundSize: CGFloat = 40
    private let iconSize: CGFloat = 24
    private let iconTitleSpacing: CGFloat = 16

    private var trailingTitleConstraint: NSLayoutConstraint!
    private var trailingTagConstraint: NSLayoutConstraint!

    private func setup() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = Color.background

        let stackView = UIStackView(arrangedSubviews: [betaLabel, demoLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8

        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)

        contentView.layoutMargins = .init(top: 32, left: 24, bottom: 32, right: 24)

        iconBackgroundView.backgroundColor = Color.accent
        iconBackgroundView.clipsToBounds = true
        iconBackgroundView.layer.cornerRadius = iconBackgroundSize / 2
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Color.background
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Font.body1
        titleLabel.textColor = Color.label

        stackView.translatesAutoresizingMaskIntoConstraints = false
        betaLabel.isHidden = true
        demoLabel.isHidden = true

        separatorInset.left = contentView.layoutMargins.left + iconSize + iconTitleSpacing
        separatorInset.right = contentView.layoutMargins.right

        trailingTitleConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor)
        trailingTagConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor)

        NSLayoutConstraint.activate([
            iconBackgroundView.widthAnchor.constraint(equalToConstant: iconBackgroundSize),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: iconBackgroundSize),
            iconBackgroundView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconBackgroundView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconBackgroundView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconBackgroundView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -iconTitleSpacing),

            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.lastBaselineAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            trailingTitleConstraint,

            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            stackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        setDemoTagLabel(false)
        setBetaTagLabel(false)
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        separatorInset.left = contentView.layoutMargins.left + iconBackgroundSize + iconTitleSpacing
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

    func setIcon(_ icon: Icon) {
        iconView.image = UIImage(icon: icon)?.withRenderingMode(.alwaysTemplate)
    }

    func setTitle(text: String) {
        titleLabel.text = text
    }

    func setBetaTagLabel(_ visible: Bool) {
        betaLabel.providerTag = ProviderTag.beta
        betaLabel.isHidden = !visible
        trailingTitleConstraint.isActive = !visible
        trailingTagConstraint.isActive = visible
    }

    func setDemoTagLabel(_ visible: Bool) {
        demoLabel.providerTag = ProviderTag.demo
        demoLabel.isHidden = !visible
        trailingTitleConstraint.isActive = !visible
        trailingTagConstraint.isActive = visible
    }
}
