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

    private var _isChecked: Bool = false

    var isChecked: Bool {
        get {
            return _isChecked
        }
        set {
            _isChecked = newValue
            circleLayer.strokeEnd = newValue ? 0 : 1
            checkmarkLayer.strokeEnd = newValue ? 0 : 1
        }
    }

    func setChecked(_ checked: Bool, animated: Bool) {
        if animated {
            if checked {
                let circleAnimation = CABasicAnimation(keyPath: "strokeEnd")
                circleAnimation.duration = 0.3
                circleAnimation.fromValue = 0
                circleAnimation.toValue = 1
                circleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                circleLayer.add(circleAnimation, forKey: "CheckAnimation")
                circleLayer.strokeEnd = 1

                let keyframeAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
                keyframeAnimation.duration = 1.0
                keyframeAnimation.values = [0.0, 0.0, 0.33, 0.33, 1.0]
                keyframeAnimation.keyTimes = [0.0, 0.4, 0.6, 0.7, 1.0]
                keyframeAnimation.timingFunctions = [
                    CAMediaTimingFunction(name: .linear),
                    CAMediaTimingFunction(name: .easeOut),
                    CAMediaTimingFunction(name: .linear),
                    CAMediaTimingFunction(name: .easeOut)
                ]
                checkmarkLayer.add(keyframeAnimation, forKey: "CheckAnimation")
                checkmarkLayer.strokeEnd = 1
            } else {
                let circleAnimation = CABasicAnimation(keyPath: "strokeEnd")
                circleAnimation.duration = 0.4
                circleAnimation.fromValue = 1
                circleAnimation.toValue = 0
                circleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                circleLayer.add(circleAnimation, forKey: "UncheckAnimation")
                circleLayer.strokeEnd = 0

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.duration = 0.4
                animation.fromValue = 1
                animation.toValue = 0
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                checkmarkLayer.add(animation, forKey: "UncheckAnimation")
                checkmarkLayer.strokeEnd = 0
            }
            _isChecked = checked
        } else {
            isChecked = checked
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
            "strokeEnd": NSNull()
        ]
        checkmarkLayer.actions = [
            "strokeEnd": NSNull()
        ]

        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.lineWidth = style.lineWidth
        checkmarkLayer.strokeColor = tintColor.cgColor
        checkmarkLayer.strokeEnd = isChecked ? 1 : 0
        layer.addSublayer(checkmarkLayer)

        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)

        isUserInteractionEnabled = false

        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = tintColor.cgColor
        circleLayer.strokeEnd = isChecked ? 1 : 0
        circleLayer.lineWidth = style.lineWidth
        circleLayer.setAffineTransform(CGAffineTransform(rotationAngle: -(.pi / 2)))
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

        circleLayer.strokeColor = tintColor.cgColor
        checkmarkLayer.strokeColor = tintColor.cgColor
    }
}
