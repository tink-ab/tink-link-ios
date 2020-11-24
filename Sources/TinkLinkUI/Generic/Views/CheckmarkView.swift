import UIKit

final class CheckmarkView: UIView {
    enum Style {
        case `default`
        case large

        fileprivate var size: CGSize {
            return CGSize(width: 22 * scale, height: 22 * scale)
        }

        fileprivate var scale: CGFloat {
            switch self {
            case .default:
                return 1.0
            case .large:
                return 40.0 / 22.0
            }
        }

        fileprivate var lineWidth: CGFloat {
            switch self {
            case .default:
                return 1.0
            case .large:
                return 2.0
            }
        }
    }

    var style: Style = .default {
        didSet {
            circleLayer.lineWidth = style.lineWidth
            checkmarkLayer.lineWidth = style.lineWidth
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    public var isChecked: Bool = false {
        didSet {
            circleLayer.opacity = isChecked ? 0 : 1
        }
    }

    public var isBorderHidden: Bool = true {
        didSet {
            circleLayer.isHidden = isBorderHidden
        }
    }

    @objc public dynamic var strokeTintColor: UIColor = .white {
        didSet {
            checkmarkLayer.strokeColor = strokeTintColor.cgColor
        }
    }

    private let circleLayer = CAShapeLayer()
    private let checkmarkLayer = CAShapeLayer()

    convenience init(style: Style = .default) {
        self.init(frame: CGRect(origin: .zero, size: style.size))
        self.style = style
        checkmarkLayer.lineWidth = style.lineWidth
        circleLayer.lineWidth = style.lineWidth
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        circleLayer.actions = [
            "opacity": NSNull()
        ]

        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.lineWidth = style.lineWidth
        checkmarkLayer.strokeColor = strokeTintColor.cgColor
        layer.addSublayer(checkmarkLayer)

        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)

        isUserInteractionEnabled = false

        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = Color.accent.cgColor
        circleLayer.lineWidth = style.lineWidth
        layer.addSublayer(circleLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 5 * style.scale, y: 11.5 * style.scale))
        path.addLine(to: CGPoint(x: 8.5 * style.scale, y: 15 * style.scale))
        path.addLine(to: CGPoint(x: 16.5 * style.scale, y: 7 * style.scale))
        checkmarkLayer.path = path.cgPath

        let circleRect = CGRect(origin: .zero, size: style.size)
        checkmarkLayer.frame = circleRect
        circleLayer.path = CGPath(ellipseIn: circleRect, transform: nil)

        let circleFrame = CGRect(
            origin: CGPoint(
                x: (bounds.width - style.size.width) * 0.5,
                y: (bounds.height - style.size.height) * 0.5
            ),
            size: style.size
        )

        circleLayer.frame = circleFrame
    }

    override var intrinsicContentSize: CGSize { style.size }

    override func tintColorDidChange() {
        super.tintColorDidChange()

    }
}
