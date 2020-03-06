import UIKit

class BorderedCornersView: UIView {
    var cornerDashLineLength: CGFloat = 50
    var cornerRadius: CGFloat = 5

    var corners: UIRectCorner = .allCorners {
        didSet {
            setupCornerLayers()
            setNeedsLayout()
        }
    }

    private var cornerLayers = [UIRectCorner.RawValue: CAShapeLayer]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCornerLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()


        cornerLayers.values.forEach { $0.strokeColor = tintColor.cgColor }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !cornerLayers.isEmpty else {
            return
        }

        if corners.contains(.topLeft) {
            let layer = cornerLayers[UIRectCorner.topLeft.rawValue]
            layer?.path = generateTopLeftTemplatePath()
        }
        if corners.contains(.topRight) {
            let layer = cornerLayers[UIRectCorner.topRight.rawValue]
            layer?.path = generateTopLeftTemplatePath()
            let topRightLayerTransform = CGAffineTransform(translationX: frame.width, y: 0).rotated(by: 0.5 * .pi)
            layer?.setAffineTransform(topRightLayerTransform)
        }
        if corners.contains(.bottomLeft) {
            let layer = cornerLayers[UIRectCorner.bottomLeft.rawValue]
            layer?.path = generateTopLeftTemplatePath()
            let bottomLeftLayerTransform = CGAffineTransform(translationX: 0, y: frame.height).rotated(by: -0.5 * .pi)
            layer?.setAffineTransform(bottomLeftLayerTransform)
        }
        if corners.contains(.bottomRight) {
            let layer = cornerLayers[UIRectCorner.bottomRight.rawValue]
            layer?.path = generateTopLeftTemplatePath()
            let bottomRightLayerTransform = CGAffineTransform(translationX: frame.width, y: frame.height).rotated(by: .pi)
            layer?.setAffineTransform(bottomRightLayerTransform)
        }
    }

    private func setupCornerLayers() {

        cornerLayers.removeAll()
        if corners.contains(.topLeft) {
            let cornerLayer = makeBorderLayer()
            cornerLayers[UIRectCorner.topLeft.rawValue] = cornerLayer
            layer.addSublayer(cornerLayer)
        }
        if corners.contains(.topRight) {
            let cornerLayer = makeBorderLayer()
            cornerLayers[UIRectCorner.topRight.rawValue] = cornerLayer
            layer.addSublayer(cornerLayer)
        }
        if corners.contains(.bottomLeft) {
            let cornerLayer = makeBorderLayer()
            cornerLayers[UIRectCorner.bottomLeft.rawValue] = cornerLayer
            layer.addSublayer(cornerLayer)
        }
        if corners.contains(.bottomRight) {
            let cornerLayer = makeBorderLayer()
            cornerLayers[UIRectCorner.bottomRight.rawValue] = cornerLayer
            layer.addSublayer(cornerLayer)
        }
    }

    private func generateTopLeftTemplatePath() -> CGPath {
        let topLeftPath = CGMutablePath()
        let topLeftPathYPosition = cornerDashLineLength / 2
        let origin = CGPoint(x: 0, y: topLeftPathYPosition)
        topLeftPath.move(to: origin)
        topLeftPath.addLine(to: CGPoint(x: 0, y: cornerRadius))
        topLeftPath.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: false)
        topLeftPath.addLine(to: CGPoint(x: cornerDashLineLength / 2, y: 0))

        return topLeftPath
    }

    private func makeBorderLayer() -> CAShapeLayer {
        let templateLayer = CAShapeLayer()
        templateLayer.fillColor = UIColor.clear.cgColor
        templateLayer.strokeColor = tintColor.cgColor
        templateLayer.lineWidth = 4
        return templateLayer
    }
}
