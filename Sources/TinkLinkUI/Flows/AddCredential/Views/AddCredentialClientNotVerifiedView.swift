import UIKit

class AddCredentialClientNotVerifiedView: UIView {
    private let contentView = UIView()
    private let unVerifiedLabel = UILabel()

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = Color.background
        layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)

        contentView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Color.critical.cgColor
        contentView.layer.cornerRadius = 16

        unVerifiedLabel.textColor = Color.critical
        unVerifiedLabel.translatesAutoresizingMaskIntoConstraints = false
        unVerifiedLabel.text = NSLocalizedString("AddCredentials.Warning.UnVerifiedUser", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Unverified - This solution is only made for development purposes. Do not enter you bank credentials unless you trust the developer.", comment: "Text for the warning shown when the user is unverified.")
        unVerifiedLabel.numberOfLines = 0
        unVerifiedLabel.font = Font.regular(.deci)

        addSubview(contentView)
        contentView.addSubview(unVerifiedLabel)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            unVerifiedLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            unVerifiedLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            unVerifiedLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            unVerifiedLabel.lastBaselineAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
