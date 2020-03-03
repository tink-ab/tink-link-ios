import UIKit

class BorderCornerRadiusImageView: UIImageView {
    enum RadiusCorner: Hashable {
        case topRight
        case topLeft
        case bottomRight
        case bottomLeft

        static let all: Set<RadiusCorner> = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    var radiusCorenrs: Set<RadiusCorner> = RadiusCorner.all

    var cornerDashLineLength: CGFloat = 50
    var cornerRadius: CGFloat = 5

    override func layoutSubviews() {
        super.layoutSubviews()

        for radiusCorenr in radiusCorenrs {
            switch radiusCorenr {
            case .topLeft:
                let cornerLayer = generateTopLeftTemplateLayer()
                layer.addSublayer(cornerLayer)
            case .topRight:
                let cornerLayer = generateTopLeftTemplateLayer()
                let topRightLayerTransform = CGAffineTransform(translationX: frame.width, y: 0).rotated(by: 0.5 * .pi)
                cornerLayer.setAffineTransform(topRightLayerTransform)
                layer.addSublayer(cornerLayer)
            case .bottomLeft:
                let cornerLayer = generateTopLeftTemplateLayer()
                let bottomLeftLayerTransform = CGAffineTransform(translationX: 0, y: frame.height).rotated(by: -0.5 * .pi)
                cornerLayer.setAffineTransform(bottomLeftLayerTransform)
                layer.addSublayer(cornerLayer)
            case .bottomRight:
                let cornerLayer = generateTopLeftTemplateLayer()
                let bottomRightLayerTransform = CGAffineTransform(translationX: frame.width, y: frame.height).rotated(by: .pi)
                cornerLayer.setAffineTransform(bottomRightLayerTransform)
                layer.addSublayer(cornerLayer)
            }
        }
    }

    private func generateTopLeftTemplateLayer() -> CALayer {
        let topLeftPath = CGMutablePath()
        let topLeftPathYPosition = cornerDashLineLength / 2
        let origin = CGPoint(x: 0, y: topLeftPathYPosition)
        topLeftPath.move(to: origin)
        topLeftPath.addLine(to: CGPoint(x: 0, y: cornerRadius))
        topLeftPath.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: false)
        topLeftPath.addLine(to: CGPoint(x: cornerDashLineLength / 2, y: 0))

        let topLeftTemplateLayer = CAShapeLayer()
        topLeftTemplateLayer.fillColor = UIColor.clear.cgColor
        topLeftTemplateLayer.strokeColor = tintColor.cgColor
        topLeftTemplateLayer.lineWidth = 4
        topLeftTemplateLayer.path = topLeftPath
        return topLeftTemplateLayer
    }
}
