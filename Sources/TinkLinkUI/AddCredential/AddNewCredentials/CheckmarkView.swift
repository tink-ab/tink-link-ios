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
                return 2.5
            }
        }
    }

    var style: Style = .default {
        didSet {
            checkmarkLayer.lineWidth = 1 * style.scale
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    public var isChecked: Bool = false {
        didSet {
            circleLayer.opacity = isChecked ? 0 : 1
            checkboxLayer.opacity = isChecked ? 1 : 0
        }
    }

    public var isBorderHidden: Bool = true {
        didSet {
            circleLayer.isHidden = isBorderHidden
        }
    }

    @objc dynamic public var strokeTintColor: UIColor = .white {
        didSet {
            checkmarkLayer.strokeColor = strokeTintColor.cgColor
        }
    }

    private let circleLayer = CAShapeLayer()
    private let checkboxLayer = CAShapeLayer()
    private let checkmarkLayer = CAShapeLayer()

    convenience public init(style: Style = .default) {
        self.init(frame: CGRect(origin: .zero, size: style.size))
        self.style = style
        checkmarkLayer.lineWidth = 1 * style.scale
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        circleLayer.actions = [
            "opacity": NSNull()
        ]
        checkboxLayer.actions = [
            "opacity": NSNull()
        ]

        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.lineWidth = 1 * style.scale
        checkmarkLayer.strokeColor = strokeTintColor.cgColor
        checkboxLayer.addSublayer(checkmarkLayer)

        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)

        isUserInteractionEnabled = false

        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = Color.accent.cgColor
        layer.addSublayer(circleLayer)

        checkboxLayer.fillColor = tintColor.cgColor
        checkboxLayer.opacity = 0.0
        layer.addSublayer(checkboxLayer)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 5 * style.scale, y: 11.5 * style.scale))
        path.addLine(to: CGPoint(x: 8.5 * style.scale, y: 15 * style.scale))
        path.addLine(to: CGPoint(x: 16.5 * style.scale, y: 7 * style.scale))
        checkmarkLayer.path = path.cgPath

        let circleRect = CGRect(origin: .zero, size: style.size)
        checkmarkLayer.frame = circleRect
        circleLayer.path = CGPath(ellipseIn: circleRect, transform: nil)
        checkboxLayer.path = CGPath(ellipseIn: circleRect, transform: nil)

        let circleFrame = CGRect(
            origin: CGPoint(
                x: (bounds.width - style.size.width) * 0.5,
                y: (bounds.height - style.size.height) * 0.5
            ),
            size: style.size
        )

        circleLayer.frame = circleFrame
        checkboxLayer.frame = circleFrame
    }
    
    override public var intrinsicContentSize: CGSize { style.size }

    public override func tintColorDidChange() {
        super.tintColorDidChange()

        checkboxLayer.fillColor = tintColor.cgColor
    }
}

