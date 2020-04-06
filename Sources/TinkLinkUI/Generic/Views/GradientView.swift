import UIKit

final class GradientView: UIView {

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override class var layerClass: AnyClass { CAGradientLayer.self }

    var colors: [UIColor] {
        get { (gradientLayer.colors as? [CGColor] ?? []).map(UIColor.init(cgColor:)) }
        set { gradientLayer.colors = newValue.map { $0.cgColor } }
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
