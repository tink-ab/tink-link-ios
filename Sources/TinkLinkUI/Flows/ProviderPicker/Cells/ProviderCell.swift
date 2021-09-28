import UIKit
import TinkLink

class ProviderCell: UITableViewCell, ReusableCell {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let demoTagLabel = DemoTagView()

    private var imageLoadingHandle: ImageLoader.ImageLoadingTaskManager.Handle?

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

    private var trailingTitleConstraint: NSLayoutConstraint?
    private var trailingTagConstraint: NSLayoutConstraint?

    private func setup() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = Color.background

        contentView.addSubview(iconView)

        contentView.layoutMargins = .init(top: 32, left: 24, bottom: 32, right: 24)

        iconView.contentMode = .scaleAspectFit

        contentView.addSubview(titleLabel)
        contentView.addSubview(demoTagLabel)
        contentView.addSubview(descriptionLabel)

        titleLabel.numberOfLines = 0
        titleLabel.font = Font.body1
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = Color.label

        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = Font.body2
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textColor = Color.secondaryLabel

        demoTagLabel.isHidden = true

        separatorInset.left = contentView.layoutMargins.left + iconSize + iconTitleSpacing
        separatorInset.right = contentView.layoutMargins.right

        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        demoTagLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        let trailingTitleConstraint: NSLayoutConstraint
        trailingTitleConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor)
        self.trailingTitleConstraint = trailingTitleConstraint
        trailingTagConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: demoTagLabel.trailingAnchor)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: iconTitleSpacing),
            trailingTitleConstraint,

            demoTagLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            demoTagLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            demoTagLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            descriptionLabel.lastBaselineAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        iconView.image = nil
        titleLabel.text = ""
        descriptionLabel.text = ""
        setDemoTagHidden(true)
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
        imageLoadingHandle?.cancel()
        imageLoadingHandle = ImageLoader.shared.loadImage(at: url) { [weak self] result in
            let image = try? result.get()
            self?.iconView.image = image
        }
    }

    func setTitle(text: String) {
        titleLabel.text = text
    }

    func setDescription(text: String) {
        descriptionLabel.text = text
    }

    func setDemoTagHidden(_ hidden: Bool) {
        demoTagLabel.isHidden = hidden
        trailingTitleConstraint?.isActive = hidden
        trailingTagConstraint?.isActive = !hidden
    }
}
