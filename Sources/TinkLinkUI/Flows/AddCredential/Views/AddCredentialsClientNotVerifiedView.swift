import UIKit

class AddCredentialsClientNotVerifiedView: UIView {
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
        layoutMargins = .init(top: 24, left: 24, bottom: 24, right: 24)

        contentView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Color.critical.cgColor
        contentView.layer.cornerRadius = 4

        unVerifiedLabel.textColor = Color.critical
        unVerifiedLabel.translatesAutoresizingMaskIntoConstraints = false
        unVerifiedLabel.text = Strings.AddCredentials.Warning.unverifiedClient
        unVerifiedLabel.numberOfLines = 0
        unVerifiedLabel.font = Font.footnote
        unVerifiedLabel.setLineHeight(lineHeight: 20)

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
