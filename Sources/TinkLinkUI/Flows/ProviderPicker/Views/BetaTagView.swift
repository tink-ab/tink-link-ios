import UIKit

class BetaTagView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.borderWidth = 1
        layer.borderColor = Color.accent.cgColor
        layer.cornerRadius = 3

        layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 2, right: 4)

        label.text = "BETA"
        label.textColor = Color.label
        label.font = Font.body1.smallCaps

        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var firstBaselineAnchor: NSLayoutYAxisAnchor { label.firstBaselineAnchor }
    override var lastBaselineAnchor: NSLayoutYAxisAnchor { label.lastBaselineAnchor }
}
