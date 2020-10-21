import UIKit

final class AccessTypePickerHeaderView: UIView {
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = Font.body
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textColor = Color.secondaryLabel
        textLabel.numberOfLines = 0
        return textLabel
    }()

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = Color.background
        layoutMargins = .init(top: 28, left: 24, bottom: 24, right: 24)

        textLabel.text = "Due to EU regulations different account types need to be connected separately."
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textLabel.lastBaselineAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
}
