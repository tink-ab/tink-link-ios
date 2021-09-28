import UIKit

class DemoTagView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.borderWidth = 1
        layer.borderColor = Color.accent.cgColor
        layer.cornerRadius = 3

        layoutMargins = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)

        label.attributedText = NSAttributedString(string: "DEMO", attributes: [.kern: 0.75])
        label.textColor = Color.label
        label.font = Font.demo
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var firstBaselineAnchor: NSLayoutYAxisAnchor { label.firstBaselineAnchor }
    override var lastBaselineAnchor: NSLayoutYAxisAnchor { label.lastBaselineAnchor }
}
