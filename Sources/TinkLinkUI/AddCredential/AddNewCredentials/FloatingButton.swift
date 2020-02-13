import UIKit

private enum Constants {
    static let insets = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 52)
}

final class FloatingButton: UIControl {
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private var imageWidthConstraint: NSLayoutConstraint?
    private var titleCenterXConstraint: NSLayoutConstraint?

    public var minimumWidth: CGFloat = 169 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    public var textColor: UIColor = .white {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    public var text: String? {
        set {
            accessibilityLabel = newValue
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }

    public var image: UIImage? = nil {
        didSet {
            if let image = image {
                imageWidthConstraint?.constant = image.size.width + 8
                titleCenterXConstraint?.constant = image.size.width / 2
            } else {
                imageWidthConstraint?.constant = 0
                titleCenterXConstraint?.constant = 0
            }
            imageView.image = image?.withRenderingMode(.alwaysTemplate)
        }
    }

    @objc dynamic public var font: UIFont! {
        get { titleLabel.font }
        set { titleLabel.font = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        layer.cornerRadius = bounds.height / 2
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.titleLabel.textColor = self.isHighlighted ? self.textColor.withAlphaComponent(0.5) : self.textColor
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            let titleAlpha: CGFloat = isEnabled ? 1.0 : 0.2
            self.titleLabel.alpha = titleAlpha
            
        }
    }
    
    override var intrinsicContentSize: CGSize {
            let titleLabelSize = titleLabel.intrinsicContentSize
            let imageWidth = imageWidthConstraint?.constant ?? 0
            return CGSize(width: max(minimumWidth, titleLabelSize.width + Constants.insets.left + Constants.insets.right + imageWidth),
                          height: 52)
    }

    private func setup() {
        backgroundColor = Color.accent

        isAccessibilityElement = true
        accessibilityTraits = .button
        
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = font
        titleLabel.textColor = Color.background
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .left
        contentView.addSubview(imageView)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 7)
        layer.shadowRadius = 21

        let imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        self.imageWidthConstraint = imageWidthConstraint

        let titleCenterXConstraint = titleLabel.centerXAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor)
        self.titleCenterXConstraint = titleCenterXConstraint
        
        NSLayoutConstraint.activate([
            titleCenterXConstraint,
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.rightAnchor.constraint(equalTo: titleLabel.leftAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 44),
            imageWidthConstraint
            ])
    }
}
