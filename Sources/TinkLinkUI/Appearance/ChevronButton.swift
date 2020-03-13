import UIKit

public class ChevronButton: UIControl {

    private let chevronLayer = ChevronLayer()
    private let highlightLayer = CALayer()
    
    public var fillColor: UIColor? {
        get {
            return UIColor(cgColor: chevronLayer.fillColor ?? UIColor.black.cgColor)
        }
        set {
            chevronLayer.fillColor = newValue?.cgColor
        }
    }

    public var direction: ChevronDirection {
        get { chevronLayer.direction }
        set { chevronLayer.direction = newValue }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public init() {
        super.init(frame: .zero)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    public override var intrinsicContentSize: CGSize { CGSize(width: 50, height: 50) }

    public override func layoutSubviews() {
        super.layoutSubviews()

        chevronLayer.frame.origin = CGPoint(x: (bounds.width - chevronLayer.frame.width) * 0.5,
                                            y: (bounds.height - chevronLayer.frame.height) * 0.5)
        
        let highlightViewWidth = frame.width - 10
        highlightLayer.frame = CGRect(x: (frame.width - highlightViewWidth) / 2, y: (frame.height - highlightViewWidth) / 2, width: highlightViewWidth, height: highlightViewWidth)
        highlightLayer.cornerRadius = highlightViewWidth / 2
    }

    override public var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.highlightLayer.opacity = self.isHighlighted ? 1 : 0
            }
        }
    }

    public override var isEnabled: Bool {
        didSet {
            chevronLayer.opacity = isEnabled ? 1.0 : 0.2
        }
    }
}

private extension ChevronButton {
    func setup() {
        highlightLayer.opacity = 0
        highlightLayer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
        
        layer.addSublayer(highlightLayer)
        layer.addSublayer(chevronLayer)
    }
}
