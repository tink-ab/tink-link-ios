import UIKit

final class GradientView: UIView {
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override class var layerClass: AnyClass { CAGradientLayer.self }

    var colors: [UIColor] {
        didSet { gradientLayer.colors = colors.map { $0.cgColor } }
    }

    init(colors: [UIColor]) {
        self.colors = colors
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var startPoint: CGPoint {
        get { gradientLayer.startPoint }
        set { gradientLayer.startPoint = newValue }
    }

    var endPoint: CGPoint {
        get { gradientLayer.endPoint }
        set { gradientLayer.endPoint = newValue }
    }

    var locations: [CGFloat] {
        get { (gradientLayer.locations ?? []).map { CGFloat($0.doubleValue) } }
        set { gradientLayer.locations = newValue.isEmpty ? nil : newValue.map { NSNumber(value: Float($0)) } }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        gradientLayer.colors = colors.map { $0.cgColor }
    }
}
