import UIKit

class FloatingPlaceholderTextField: UITextField {

    enum InputType {
        case text
        case number
        case amount(Int)
    }

    var inputType: InputType = .text {
        didSet {
            updateInputType()
            inputFormatter?.update()
        }
    }

    private var inputFormatter: InputFormatter?

    private let underlineLayer = CAShapeLayer()
    private let placeholderLayer = CATextLayer()
    override var placeholder: String? {
        didSet {
            placeholderLayer.string = placeholder
        }
    }

    var lineWidth: CGFloat = 2.0 {
        didSet {
            underlineLayer.lineWidth = lineWidth
        }
    }

    var heightPadding: CGFloat = 8.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var text: String? {
        didSet {
            updatePlaceholderLayer()
            inputFormatter?.update()
        }
    }

    override var font: UIFont? {
        didSet {
            placeholderLayer.font = font as CFTypeRef
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override func drawPlaceholder(in rect: CGRect) {
        if placeholderLayer.frame.isEmpty {
            placeholderLayer.frame = rect
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLayer.frame = placeholderRect(forBounds: bounds)

        underlineLayer.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: lineWidth)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: underlineLayer.bounds.midY))
        path.addLine(to: CGPoint(x: underlineLayer.bounds.maxX, y: underlineLayer.bounds.midY))
        underlineLayer.path = path.cgPath
        updatePlaceholderLayer()
    }

    override var canBecomeFirstResponder: Bool { true }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            underlineLayer.strokeStart = 0.0
            underlineLayer.strokeEnd = 1.0
        }
        return result
    }

    override var canResignFirstResponder: Bool { true }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            underlineLayer.strokeStart = 0.5
            underlineLayer.strokeEnd = 0.5
        }
        return result
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += heightPadding * 2
        size.height = size.height.rounded()
        return size
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        underlineLayer.strokeColor = tintColor.cgColor
        underlineLayer.backgroundColor = Color.separator.cgColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
                return
            }
            underlineLayer.strokeColor = tintColor.cgColor
            underlineLayer.backgroundColor = Color.separator.cgColor
        }
    }
}

private extension FloatingPlaceholderTextField {
    func setup() {
        clipsToBounds = false
        backgroundColor = .clear

        font = Font.regular(.hecto)
        textColor = Color.label
        placeholderLayer.font = font as CFTypeRef
        placeholderLayer.contentsScale = UIScreen.main.scale
        placeholderLayer.string = placeholder
        placeholderLayer.foregroundColor = Color.secondaryLabel.cgColor
        placeholderLayer.anchorPoint = .zero
        layer.addSublayer(placeholderLayer)

        underlineLayer.backgroundColor = Color.separator.cgColor
        underlineLayer.lineWidth = lineWidth
        underlineLayer.fillColor = UIColor.clear.cgColor
        underlineLayer.strokeColor = tintColor.cgColor
        underlineLayer.strokeEnd = 0.5
        underlineLayer.strokeStart = 0.5
        layer.addSublayer(underlineLayer)

        updateInputType()

        addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }

    @objc
    func didChangeText(_ sender: Any) {
        updatePlaceholderLayer()
    }

    func updatePlaceholderLayer() {
        guard let font = font,
            !placeholderLayer.frame.isEmpty else { return }

        let value = text ?? ""
        let placeholderUpTop = !value.isEmpty
        let targetSize: CGFloat = placeholderUpTop ? 13.0 : font.pointSize

        placeholderLayer.fontSize = targetSize

        let placeholderFrame = placeholderRect(forBounds: bounds)
        placeholderLayer.position.x = placeholderUpTop ? 0 : placeholderLayer.frame.origin.x
        placeholderLayer.position.y = placeholderUpTop ? -targetSize : placeholderFrame.origin.y
    }

    func updateInputType() {
        switch inputType {
        case .text:
            inputFormatter = TextInputFormatter(textField: self)
        case .number:
            inputFormatter = NumericCodeInputFormatter(textField: self)
        case .amount(let digits):
            inputFormatter = NumericCodeInputFormatter(textField: self, maxDigits: digits)
        }
    }
}
