import UIKit
import Kingfisher

final class FixedImageSizeTableViewCell: UITableViewCell {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let iconSize: CGFloat = 26
    private let iconTitleSpacing: CGFloat = 15

    private func setup() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        accessoryType = .disclosureIndicator

        separatorInset.left = layoutMargins.left + iconSize + iconTitleSpacing

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -iconTitleSpacing),

            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
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
}
