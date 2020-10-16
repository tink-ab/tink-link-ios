import UIKit

final class ActivityIndicatorView: UIView {
    private let circleLayer = CAShapeLayer()
    private let size = 20 as CGFloat
    private var shouldBeAnimating = false {
        didSet {
            guard shouldBeAnimating != oldValue else {
                return
            }
            if shouldBeAnimating {
                state.start()
            } else {
                state.stop()
            }
        }
    }

    private enum AnimationState {
        case starting
        case repeating
        case stopping
        case stopped

        mutating func start() {
            if self == .repeating { return }
            self = .starting
        }

        mutating func beginRepeating() {
            self = .repeating
        }

        mutating func stop() {
            if self == .stopped { return }
            self = .stopping
        }

        mutating func didStop() {
            self = .stopped
        }
    }

    private var state: AnimationState = .stopped {
        didSet {
            guard state != oldValue else {
                return
            }
            switch state {
            case .starting:
                beginAnimation()
            case .repeating:
                startRepeatingAnimation()
            case .stopping:
                endAnimation()
            case .stopped:
                break
            }
        }
    }

    // MARK: - Initializers

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
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
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: size / 2, y: size / 2), radius: size / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)

        circleLayer.lineWidth = 2
        circleLayer.fillColor = nil
        circleLayer.strokeColor = tintColor.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap.butt
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0

        isUserInteractionEnabled = false

        layer.addSublayer(circleLayer)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.frame = CGRect(x: (bounds.width - size) / 2, y: (bounds.height - size) / 2, width: size, height: size)
    }

    override var intrinsicContentSize: CGSize { CGSize(width: size, height: size) }

    // MARK: - Color

    override func tintColorDidChange() {
        super.tintColorDidChange()
        circleLayer.strokeColor = tintColor.cgColor
    }

    // MARK: - Animation

    private enum AnimationKeys: String {
        case strokeStart
        case strokeEnd
        case rotation

        static var all: [AnimationKeys] {
            return [.strokeStart, strokeEnd, rotation]
        }
    }
}

extension ActivityIndicatorView {
    /// Indicating whether the activity indicator is currently running its animation.
    var isAnimating: Bool { state != .stopped }

    /// Starts the animation of the progress indicator.
    func startAnimating() {
        #if DEBUG
            dispatchPrecondition(condition: .onQueue(.main))
        #endif
        DispatchQueue.main.async {
            self.shouldBeAnimating = true
        }
    }

    /// Stops the animation of the progress indicator.
    func stopAnimating() {
        #if DEBUG
            dispatchPrecondition(condition: .onQueue(.main))
        #endif
        DispatchQueue.main.async {
            self.shouldBeAnimating = false
        }
    }

    func setAnimating(_ animating: Bool) {
        if animating {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
}

extension ActivityIndicatorView {
    private func beginAnimation() {
        circleLayer.isHidden = false

        let duration = 0.5 as CFTimeInterval
        do {
            let animation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            animation.values = [0.0, 0.5]
            animation.keyTimes = [0, 1]
            animation.timingFunctions = [
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            ]
            animation.repeatCount = 1
            animation.duration = duration
            animation.delegate = self
            animation.isRemovedOnCompletion = false
            circleLayer.strokeEnd = 0.5
            circleLayer.add(animation, forKey: AnimationKeys.strokeEnd.rawValue)
        }

        do {
            // Have to use `transform.rotation.z` instead of `#keyPath(CAShapeLayer.transform)` since a CATransform3D with CGFloat.pi * 2 rotation is equal to `CATransform3DIdentity`
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = CGFloat.pi * 2
            animation.repeatCount = 1
            animation.duration = duration
            animation.isRemovedOnCompletion = false
            circleLayer.transform = CATransform3DMakeRotation(CGFloat.pi * 2, 0, 0, 1)
            circleLayer.add(animation, forKey: AnimationKeys.rotation.rawValue)
        }
    }

    private func startRepeatingAnimation() {
        circleLayer.isHidden = false

        let duration = 1.25 as CFTimeInterval

        do {
            let animation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
            animation.values = [0.0, 0.5, 0.0]
            animation.keyTimes = [0, 0.5, 1]
            animation.timingFunctions = [
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            ]
            animation.repeatCount = .greatestFiniteMagnitude
            animation.duration = duration * 1.25
            animation.isRemovedOnCompletion = false
            circleLayer.add(animation, forKey: AnimationKeys.strokeStart.rawValue)
        }

        do {
            let animation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            animation.values = [0.5, 1.0, 0.5]
            animation.keyTimes = [0, 0.5, 1]
            animation.timingFunctions = [
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            ]
            animation.repeatCount = .greatestFiniteMagnitude
            animation.duration = duration * 1.75
            animation.isRemovedOnCompletion = false
            circleLayer.add(animation, forKey: AnimationKeys.strokeEnd.rawValue)
        }

        do {
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = CGFloat.pi * 2
            animation.repeatCount = .greatestFiniteMagnitude
            animation.duration = duration * 0.5
            animation.isRemovedOnCompletion = false
            circleLayer.add(animation, forKey: AnimationKeys.rotation.rawValue)
        }
    }

    private func endAnimation() {
        circleLayer.isHidden = true
    }
}

extension ActivityIndicatorView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            state.stop()
        } else if shouldBeAnimating {
            state.beginRepeating()
        }
    }

    @objc
    private func applicationDidEnterBackground() {
        state.stop()
    }

    @objc
    private func applicationWillEnterForeground() {
        guard shouldBeAnimating else { return }
        state.beginRepeating()
    }
}

extension ActivityIndicatorView: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {}

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if shouldBeAnimating {
            state.beginRepeating()
        } else {
            for key in AnimationKeys.all {
                circleLayer.removeAnimation(forKey: key.rawValue)
            }
            state.didStop()
        }
    }
}
