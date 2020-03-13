import UIKit

enum ChevronDirection {
    case right
    case left
    case up
    case down
}

enum ChevronSize {
    case small
    case large
}

class ChevronLayer: CAShapeLayer {

    var size: ChevronSize = .large {
        didSet {
            updatePath()
        }
    }

    var direction: ChevronDirection = .left {
        didSet {
            updatePath()
        }
    }

    var boundingBox: CGRect {
        if let path = path {
            return path.boundingBox
        }

        return .zero
    }

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override init(layer: Any) {
        super.init(layer: layer)

        setup()
    }
}

private extension ChevronLayer {
    func setup() {
        fillColor = UIColor.blue.cgColor
        frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        updatePath()
    }

    func updatePath() {
        path = chevronPath(for: direction, size: size)
    }

    func chevronPath(for direction: ChevronDirection, size: ChevronSize) -> CGPath {
        let chevronPath = UIBezierPath()
        
        switch size {
        case .small:
            chevronPath.move(to: CGPoint(x: 0, y: 4.06))
            chevronPath.addLine(to: CGPoint(x: 4.65, y: 0.0))
            chevronPath.addLine(to: CGPoint(x: 5.63, y: 1.13))
            chevronPath.addLine(to: CGPoint(x: 2.28, y: 4.06))
            chevronPath.addLine(to: CGPoint(x: 5.64, y: 7))
            chevronPath.addLine(to: CGPoint(x: 4.65, y: 8.13))
        case .large:
            chevronPath.move(to: CGPoint(x: 0, y: 6))
            chevronPath.addLine(to: CGPoint(x: 6.38, y: 0.0))
            chevronPath.addLine(to: CGPoint(x: 7.58, y: 1.13))
            chevronPath.addLine(to: CGPoint(x: 2.4, y: 6.0))
            chevronPath.addLine(to: CGPoint(x: 7.58, y: 10.87))
            chevronPath.addLine(to: CGPoint(x: 6.38, y: 12))
        }
        chevronPath.close()

        let offsetx = chevronPath.bounds.midX / 2
        let offsety = chevronPath.bounds.midX / 2

        var transform: CGAffineTransform = .identity
        switch direction {
        case .down:
            transform = transform.translatedBy(x: 0,
                                               y: chevronPath.bounds.width + offsetx)
            transform = transform.rotated(by: -.pi / 2)
        case .up:
            transform = transform.translatedBy(x: chevronPath.bounds.height,
                                               y: offsety)
            transform = transform.rotated(by: .pi / 2)
        case .right:
            transform = transform.translatedBy(x: chevronPath.bounds.width + offsetx,
                                               y: chevronPath.bounds.height)
            transform = transform.rotated(by: .pi)
        default:
            transform = transform.translatedBy(x: offsetx, y: 0)
        }
        chevronPath.apply(transform)

        return chevronPath.cgPath
    }
}
