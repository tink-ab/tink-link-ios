import UIKit

public class FloatingPlaceholderTextField: UITextField {

    public enum InputType {
        case text
        case number
        case amount(Int)
    }

    public var inputType: InputType = .text {
        didSet {
            updateInputType()
            inputFormatter?.update()
        }
    }

    private var inputFormatter: InputFormatter?

    private let underlineLayer = CAShapeLayer()
    private let placeholderLayer = CATextLayer()
    override public var placeholder: String? {
        didSet {
            placeholderLayer.string = placeholder
        }
    }

    private let helpLabel = UILabel()

    public var placeholderTextColor: UIColor! {
        set {
            placeholderLayer.foregroundColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: placeholderLayer.foregroundColor ?? UIColor.lightText.cgColor)
        }
    }

    public var string: String? { attributedText?.string ?? text }

    public var lineWidth: CGFloat = 2.0 {
        didSet {
            underlineLayer.lineWidth = lineWidth
        }
    }

    public var heightPadding: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    private lazy var prefixLabel = UILabel()
    public var prefix: String? {
        didSet {
            updatePrefix()
        }
    }

    private lazy var suffixLabel = UILabel()
    public var suffix: String? {
        didSet {
            updateSuffix()
        }
    }

    public override var text: String? {
        didSet {
            updatePlaceholderLayer()
            inputFormatter?.update()
        }
    }

    public override var font: UIFont? {
        didSet {
            if prefix != nil {
                prefixLabel.font = font
            }
            if suffix != nil {
                suffixLabel.font = font
            }
            placeholderLayer.font = font as CFTypeRef
        }
    }

    public var helpFont: UIFont? {
        didSet {
            helpLabel.font = helpFont
            setNeedsLayout()
        }
    }

    public var helpColor: UIColor? {
        didSet {
            helpLabel.textColor = helpColor
        }
    }

    public var helpText: String? {
        didSet {
            helpLabel.text = helpText
            setNeedsLayout()
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override public func drawPlaceholder(in rect: CGRect) {
        if placeholderLayer.frame.isEmpty {
            placeholderLayer.frame = rect
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLayer.frame = placeholderRect(forBounds: bounds)

        underlineLayer.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: lineWidth)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: underlineLayer.bounds.midY))
        path.addLine(to: CGPoint(x: underlineLayer.bounds.maxX, y: underlineLayer.bounds.midY))
        underlineLayer.path = path.cgPath
        updatePlaceholderLayer()

        helpLabel.sizeToFit()
        helpLabel.frame = CGRect(x: 0, y: underlineLayer.frame.maxY + 4, width: frame.width, height: helpLabel.frame.height)

        if let range = textRange(from: beginningOfDocument, to: endOfDocument) {
            let textFrame = firstRect(for: range)
            suffixLabel.sizeToFit()
            suffixLabel.frame.origin = CGPoint(x: textFrame.maxX, y: textFrame.minY)
            suffixLabel.frame.size.height = textFrame.height
        } else {
            suffixLabel.frame = rightViewRect(forBounds: bounds)
        }
    }

    public override var canBecomeFirstResponder: Bool { true }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            underlineLayer.strokeStart = 0.0
            underlineLayer.strokeEnd = 1.0
        }
        return result
    }

    public override var canResignFirstResponder: Bool { true }

    public override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            underlineLayer.strokeStart = 0.5
            underlineLayer.strokeEnd = 0.5
        }
        return result
    }

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += heightPadding * 2
        size.height = size.height.rounded()
        return size
    }

    public override func tintColorDidChange() {
        super.tintColorDidChange()

        underlineLayer.strokeColor = tintColor.cgColor
        underlineLayer.backgroundColor = Color.separator.cgColor
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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

        placeholderLayer.font = font as CFTypeRef
        placeholderLayer.contentsScale = UIScreen.main.scale
        placeholderLayer.string = placeholder
        placeholderLayer.foregroundColor = UIColor.lightText.cgColor
        placeholderLayer.anchorPoint = .zero
        layer.addSublayer(placeholderLayer)

        underlineLayer.backgroundColor = Color.separator.cgColor
        underlineLayer.lineWidth = lineWidth
        underlineLayer.fillColor = UIColor.clear.cgColor
        underlineLayer.strokeColor = tintColor.cgColor
        underlineLayer.strokeEnd = 0.5
        underlineLayer.strokeStart = 0.5

        layer.addSublayer(underlineLayer)

        helpLabel.numberOfLines = 2
        addSubview(helpLabel)

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
        let placeholderUpTop = prefix != nil || !value.isEmpty || suffix != nil
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
            inputFormatter = NumberInputFormatter(textField: self)
        case .amount(let digits):
            inputFormatter = NumberInputFormatter(textField: self, maxDigits: digits)
        }
    }

    func updatePrefix() {
        if let prefix = prefix, !prefix.isEmpty {
            prefixLabel.font = font
            prefixLabel.text = prefix
            prefixLabel.textColor = textColor
            prefixLabel.sizeToFit()

            leftView = prefixLabel
            leftViewMode = .always
        } else {
            leftView = nil
            leftViewMode = .never
        }
    }

    func updateSuffix() {
        if let suffix = suffix, !suffix.isEmpty {
            suffixLabel.font = font
            suffixLabel.text = suffix
            suffixLabel.textColor = textColor
            addSubview(suffixLabel)
        } else {
            suffixLabel.removeFromSuperview()
        }
    }
}
