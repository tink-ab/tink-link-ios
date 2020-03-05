import UIKit

class BorderCornerRadiusView: UIView {
    var cornerDashLineLength: CGFloat = 50
    var cornerRadius: CGFloat = 5

    var radiusCorner: UIRectCorner = .allCorners {
        didSet {
            setupCornerLayers()
            setNeedsLayout()
        }
    }

    private var cornerLayersToUpdate = [CAShapeLayer]()
    private var updatedCornerLayers = [CAShapeLayer]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCornerLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        updatedCornerLayers.forEach { $0.strokeColor = tintColor.cgColor }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !cornerLayersToUpdate.isEmpty else {
            return
        }

        if radiusCorner.contains(.topLeft) {
            let layer = cornerLayersToUpdate.removeFirst()
            layer.path = generateTopLeftTemplatePath()
            updatedCornerLayers.append(layer)
        }
        if radiusCorner.contains(.topRight) {
            let layer = cornerLayersToUpdate.removeFirst()
            layer.path = generateTopLeftTemplatePath()
            let topRightLayerTransform = CGAffineTransform(translationX: frame.width, y: 0).rotated(by: 0.5 * .pi)
            layer.setAffineTransform(topRightLayerTransform)
            updatedCornerLayers.append(layer)
        }
        if radiusCorner.contains(.bottomLeft) {
            let layer = cornerLayersToUpdate.removeFirst()
            layer.path = generateTopLeftTemplatePath()
            let bottomLeftLayerTransform = CGAffineTransform(translationX: 0, y: frame.height).rotated(by: -0.5 * .pi)
            layer.setAffineTransform(bottomLeftLayerTransform)
            updatedCornerLayers.append(layer)
        }
        if radiusCorner.contains(.bottomRight) {
            let layer = cornerLayersToUpdate.removeFirst()
            layer.path = generateTopLeftTemplatePath()
            let bottomRightLayerTransform = CGAffineTransform(translationX: frame.width, y: frame.height).rotated(by: .pi)
            layer.setAffineTransform(bottomRightLayerTransform)
            updatedCornerLayers.append(layer)
        }
    }

    private func setupCornerLayers() {
        updatedCornerLayers.forEach { $0.removeFromSuperlayer() }

        cornerLayersToUpdate.removeAll()
        updatedCornerLayers.removeAll()

        if radiusCorner.contains(.topLeft) {
            let cornerLayer = generateBorderLayer()
            cornerLayersToUpdate.append(cornerLayer)
            layer.addSublayer(cornerLayer)
        }
        if radiusCorner.contains(.topRight) {
            let cornerLayer = generateBorderLayer()
            cornerLayersToUpdate.append(cornerLayer)
            layer.addSublayer(cornerLayer)
        }
        if radiusCorner.contains(.bottomLeft) {
            let cornerLayer = generateBorderLayer()
            cornerLayersToUpdate.append(cornerLayer)
            layer.addSublayer(cornerLayer)
        }
        if radiusCorner.contains(.bottomRight) {
            let cornerLayer = generateBorderLayer()
            cornerLayersToUpdate.append(cornerLayer)
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

    private func generateBorderLayer() -> CAShapeLayer {
        let templateLayer = CAShapeLayer()
        templateLayer.fillColor = UIColor.clear.cgColor
        templateLayer.strokeColor = tintColor.cgColor
        templateLayer.lineWidth = 4
        return templateLayer
    }
}
