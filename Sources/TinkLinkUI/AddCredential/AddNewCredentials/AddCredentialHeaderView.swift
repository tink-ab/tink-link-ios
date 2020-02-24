import UIKit
import TinkLink
import Kingfisher

protocol AddCredentialHeaderViewDelegate: AnyObject {
    func addCredentialHeaderViewDidTapReadMore(_ addCredentialHeaderView: AddCredentialHeaderView)
}

final class AddCredentialHeaderView: UIView {
    private lazy var bankIconView: UIImageView = {
        let bankIconView = UIImageView()
        bankIconView.contentMode = .scaleAspectFit
        return bankIconView
    }()
    private lazy var bankLabel: UILabel = {
        let bankLabel = UILabel()
        bankLabel.font = Font.semibold(.deci)
        bankLabel.textColor = Color.label
        bankLabel.numberOfLines = 0
        return bankLabel
    }()
    private let userInfoIconBackgroundView: UIView = {
        let userInfoIconBackgroundView = UIView()
        userInfoIconBackgroundView.backgroundColor = Color.accent.withAlphaComponent(0.1)
        return userInfoIconBackgroundView
    }()
    private let userInfoIconView: UIImageView = {
        let userInfoIconView = UIImageView()
        userInfoIconView.tintColor = Color.accent
        userInfoIconView.image = UIImage(icon: .profile)?.withRenderingMode(.alwaysTemplate)
        return userInfoIconView
    }()
    private let userInfoLabel: UILabel = {
        let userInfoLabel = UILabel()
        userInfoLabel.font = Font.semibold(.deci)
        userInfoLabel.textColor = Color.label
        userInfoLabel.numberOfLines = 0
        return userInfoLabel
    }()
    private lazy var userInfoDescription: UITextView = {
        let userInfoDescription = UITextView()
        userInfoDescription.textContainerInset = .zero
        userInfoDescription.textContainer.lineFragmentPadding = 0
        userInfoDescription.font = Font.regular(.micro)
        userInfoDescription.textColor = Color.label
        userInfoDescription.isScrollEnabled = false
        userInfoDescription.backgroundColor = .clear
        userInfoDescription.isEditable = false
        userInfoDescription.delegate = self
        return userInfoDescription
    }()
    private lazy var dashLine: UIView = {
        let dashLine = UIView()
        dashLine.backgroundColor = .clear
        dashLine.layer.addSublayer(dashLayer)
        return dashLine
    }()
    private lazy var dashLayer: CAShapeLayer = {
        let dashLayer = CAShapeLayer()
        dashLayer.fillColor = UIColor.clear.cgColor
        dashLayer.strokeColor = UIColor.darkGray.cgColor
        dashLayer.lineWidth = 1
        dashLayer.lineDashPattern = [1,3]
        return dashLayer
    }()

    private var userInfoLabelBottomSpace: NSLayoutConstraint?
    private var userInfoDescriptionBottomSpace: NSLayoutConstraint?

    private var readMoreRange: NSRange?
    private var userInfoDescriptionTopConstraint: NSLayoutConstraint?
    private var userInfoDescriptionEmptyUsernameConstraint: NSLayoutConstraint?

    weak var delegate: AddCredentialHeaderViewDelegate?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = Color.accentBackground
        layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)

        bankLabel.translatesAutoresizingMaskIntoConstraints = false
        bankIconView.translatesAutoresizingMaskIntoConstraints = false
        dashLine.translatesAutoresizingMaskIntoConstraints = false
        userInfoIconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        userInfoIconView.translatesAutoresizingMaskIntoConstraints = false
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoDescription.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bankLabel)
        addSubview(bankIconView)
        addSubview(dashLine)
        addSubview(userInfoIconBackgroundView)
        addSubview(userInfoIconView)
        addSubview(userInfoLabel)
        addSubview(userInfoDescription)

        let userInfoDescriptionTopConstraint = userInfoDescription.topAnchor.constraint(equalTo: userInfoLabel.lastBaselineAnchor, constant: 8)
        self.userInfoDescriptionTopConstraint = userInfoDescriptionTopConstraint
        let userInfoDescriptionEmptyUsernameConstraint = userInfoDescription.centerYAnchor.constraint(equalTo: userInfoIconView.centerYAnchor)
        self.userInfoDescriptionEmptyUsernameConstraint = userInfoDescriptionEmptyUsernameConstraint

        userInfoLabelBottomSpace = userInfoLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)

        let userInfoDescriptionBottomSpace = userInfoDescription.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        self.userInfoDescriptionBottomSpace = userInfoDescriptionBottomSpace

        NSLayoutConstraint.activate([
            bankIconView.widthAnchor.constraint(equalToConstant: 30),
            bankIconView.heightAnchor.constraint(equalToConstant: 30),
            bankIconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            bankIconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            bankIconView.trailingAnchor.constraint(equalTo: bankLabel.leadingAnchor, constant: -8),
            bankIconView.bottomAnchor.constraint(equalTo: dashLine.topAnchor),

            bankLabel.centerYAnchor.constraint(equalTo: bankIconView.centerYAnchor),
            bankLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            dashLine.heightAnchor.constraint(equalToConstant: 16),
            dashLine.widthAnchor.constraint(equalToConstant: 1),
            dashLine.centerXAnchor.constraint(equalTo: bankIconView.centerXAnchor),
            dashLine.bottomAnchor.constraint(equalTo: userInfoIconBackgroundView.topAnchor),

            userInfoIconBackgroundView.widthAnchor.constraint(equalToConstant: 30),
            userInfoIconBackgroundView.heightAnchor.constraint(equalToConstant: 30),
            userInfoIconBackgroundView.centerYAnchor.constraint(equalTo: userInfoIconView.centerYAnchor),
            userInfoIconBackgroundView.centerXAnchor.constraint(equalTo: userInfoIconView.centerXAnchor),
            userInfoIconView.widthAnchor.constraint(equalToConstant: 18),
            userInfoIconView.heightAnchor.constraint(equalToConstant: 18),
            userInfoIconView.centerXAnchor.constraint(equalTo: dashLine.centerXAnchor),

            userInfoLabel.leadingAnchor.constraint(equalTo: userInfoIconBackgroundView.trailingAnchor, constant: 8),
            userInfoLabel.centerYAnchor.constraint(equalTo: userInfoIconView.centerYAnchor),
            userInfoLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            userInfoDescriptionTopConstraint,
            userInfoDescription.leadingAnchor.constraint(equalTo: userInfoLabel.leadingAnchor),
            userInfoDescription.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            userInfoDescriptionBottomSpace
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userInfoIconBackgroundView.layer.cornerRadius = userInfoIconBackgroundView.frame.height / 2

        dashLayer.frame = dashLine.bounds
        let path = CGMutablePath()
        path.move(to: dashLine.bounds.origin)
        path.addLine(to: CGPoint(x: dashLine.bounds.origin.x, y: dashLine.bounds.maxY))
        dashLayer.path = path
    }

    func configure(with provider: Provider, username: String? = nil, isAggregator: Bool) {
        if let username = username, !username.isEmpty {
            userInfoLabel.text = username
            userInfoLabel.isHidden = false
            userInfoDescriptionTopConstraint?.isActive = true
            userInfoDescriptionEmptyUsernameConstraint?.isActive = false
        } else {
            userInfoLabel.isHidden = true
            userInfoDescriptionTopConstraint?.isActive = false
            userInfoDescriptionEmptyUsernameConstraint?.isActive = true
        }
        provider.image.flatMap {
            bankIconView.kf.setImage(with: ImageResource(downloadURL: $0))
        }
        bankLabel.text = provider.displayName
        let text = String(format: "%@ will obtain some of your financial information. Read More", provider.displayName)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.label,
            .font: Font.regular(.micro)
        ]
        let attributeText = NSMutableAttributedString(string: text, attributes: attributes)
        let readMoreText = "Read More"
        let readMoreRange = attributeText.mutableString.range(of: readMoreText)
        self.readMoreRange = readMoreRange
        attributeText.addAttributes([
            NSAttributedString.Key.font: Font.bold(.micro),
            NSAttributedString.Key.foregroundColor: Color.accent,
            NSAttributedString.Key.link: "",
        ], range: readMoreRange)
        userInfoDescription.attributedText = attributeText
        userInfoDescription.linkTextAttributes = [
            NSAttributedString.Key.font: Font.bold(.micro),
            NSAttributedString.Key.foregroundColor: Color.accent
        ]
        userInfoDescription.isHidden = isAggregator
        if isAggregator {
            if let constraint = userInfoLabelBottomSpace {
                NSLayoutConstraint.activate([constraint])
            }
            if let constraint = userInfoDescriptionBottomSpace {
                NSLayoutConstraint.deactivate([constraint])
            }
        } else {
            if let constraint = userInfoLabelBottomSpace {
                NSLayoutConstraint.deactivate([constraint])
            }
            if let constraint = userInfoDescriptionBottomSpace {
                NSLayoutConstraint.activate([constraint])
            }
        }
    }
}

extension AddCredentialHeaderView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            if characterRange == readMoreRange {
                delegate?.addCredentialHeaderViewDidTapReadMore(self)
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
}
