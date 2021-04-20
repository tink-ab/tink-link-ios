import UIKit

struct ProviderTag: OptionSet {
    let rawValue: Int

    static let demo = ProviderTag(rawValue: 1 << 0)
    static let beta = ProviderTag(rawValue: 1 << 1)
    static let demoAndBeta: ProviderTag = [.demo, .beta]

    public static var debugDescriptions: [(Self, String)] = [
        (.demo, "DEMO"),
        (.beta, "BETA")
    ]

    var strings: [String] {
        var strings: [String] = []
        if contains(.demo) {
            strings.append("DEMO")
        }
        if contains(.beta) {
            strings.append("BETA")
        }
        return strings
    }
}

class ProviderTagView: UIView {
    private let label = UILabel()

    var providerTag: ProviderTag {
        didSet {
            label.attributedText = NSAttributedString(string: providerTag.strings.joined(separator: " "), attributes: [.kern: 0.75])
        }
    }

    override init(frame: CGRect) {
        self.providerTag = ProviderTag.beta
        super.init(frame: frame)

        layer.borderWidth = 1
        layer.borderColor = Color.accent.cgColor
        layer.cornerRadius = 3

        layoutMargins = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)

        label.textColor = Color.label
        label.font = Font.beta

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
