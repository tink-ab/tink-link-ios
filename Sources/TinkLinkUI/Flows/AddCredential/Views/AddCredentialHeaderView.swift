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
    private let userInfoContainerView = UIView()
    private let userInfoIconBackgroundView: UIView = {
        let userInfoIconBackgroundView = UIView()
        userInfoIconBackgroundView.backgroundColor = Color.accent.withAlphaComponent(0.1)
        userInfoIconBackgroundView.layer.cornerRadius = 15

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
        let userInfoDescription = UnselectableTextView()
        userInfoDescription.textContainerInset = .zero
        userInfoDescription.textContainer.lineFragmentPadding = 0
        userInfoDescription.font = Font.regular(.micro)
        userInfoDescription.textColor = Color.label
        userInfoDescription.isScrollEnabled = false
        userInfoDescription.backgroundColor = .clear
        userInfoDescription.isEditable = false
        userInfoDescription.clipsToBounds = false
        userInfoDescription.delegate = self
        return userInfoDescription
    }()
    private lazy var dashLine: UIView = {
        let dashLine = UIView()
        dashLine.backgroundColor = .clear
        dashLine.layer.addSublayer(dashLayer)

        dashLayer.frame = CGRect(origin: dashLine.bounds.origin, size: CGSize(width: 1, height: 16))

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 16))
        dashLayer.path = path

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

    private var readMoreRange: NSRange?

    private var emptyDescriptionUserInfoLabelBottomSpace: NSLayoutConstraint?
    private var userInfoDescriptionBottomSpace: NSLayoutConstraint?

    private var userInfoDescriptionTopConstraint: NSLayoutConstraint?
    private var emptyUsernameDescriptionCenterYConstraint: NSLayoutConstraint?
    private var userInfoEmptyBottomConstraint: NSLayoutConstraint?
    private var emptyUserInfoContainerBottomConstraint: NSLayoutConstraint?
    private var userInfoContainerBottomConstraint: NSLayoutConstraint?

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
        userInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        dashLine.translatesAutoresizingMaskIntoConstraints = false
        userInfoIconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        userInfoIconView.translatesAutoresizingMaskIntoConstraints = false
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoDescription.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bankLabel)
        addSubview(bankIconView)
        addSubview(userInfoContainerView)

        userInfoContainerView.addSubview(dashLine)
        userInfoContainerView.addSubview(userInfoIconBackgroundView)
        userInfoContainerView.addSubview(userInfoIconView)
        userInfoContainerView.addSubview(userInfoLabel)
        userInfoContainerView.addSubview(userInfoDescription)

        let userInfoDescriptionTopConstraint = userInfoDescription.topAnchor.constraint(equalTo: userInfoLabel.lastBaselineAnchor, constant: 8)
        self.userInfoDescriptionTopConstraint = userInfoDescriptionTopConstraint
        emptyUsernameDescriptionCenterYConstraint = userInfoDescription.centerYAnchor.constraint(equalTo: userInfoIconView.centerYAnchor)

        let userInfoDescriptionBottomSpace = userInfoDescription.bottomAnchor.constraint(equalTo: userInfoContainerView.bottomAnchor)
        self.userInfoDescriptionBottomSpace = userInfoDescriptionBottomSpace
        emptyDescriptionUserInfoLabelBottomSpace = userInfoLabel.bottomAnchor.constraint(equalTo: userInfoContainerView.bottomAnchor)

        let userInfoContainerBottomConstraint = userInfoContainerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        self.userInfoContainerBottomConstraint = userInfoContainerBottomConstraint
        emptyUserInfoContainerBottomConstraint = bankIconView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            bankIconView.widthAnchor.constraint(equalToConstant: 30),
            bankIconView.heightAnchor.constraint(equalToConstant: 30),
            bankIconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            bankIconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            bankIconView.trailingAnchor.constraint(equalTo: bankLabel.leadingAnchor, constant: -8),

            bankLabel.centerYAnchor.constraint(equalTo: bankIconView.centerYAnchor),
            bankLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            userInfoContainerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            userInfoContainerView.topAnchor.constraint(equalTo: bankIconView.bottomAnchor),
            userInfoContainerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            userInfoContainerBottomConstraint,

            dashLine.topAnchor.constraint(equalTo: userInfoContainerView.topAnchor),
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
            userInfoLabel.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor),

            userInfoDescriptionTopConstraint,
            userInfoDescription.leadingAnchor.constraint(equalTo: userInfoLabel.leadingAnchor),
            userInfoDescription.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor),
            userInfoDescriptionBottomSpace
        ])
    }

    func configure(with provider: Provider, username: String? = nil, clientName: String, isAggregator: Bool) {
        configure(provider)
        
        let shouldHideUserInfoContainer = isAggregator && (username?.isEmpty ?? true)
        guard !shouldHideUserInfoContainer else {
            userInfoContainerView.isHidden = true
            emptyUserInfoContainerBottomConstraint?.isActive = true

            userInfoDescriptionTopConstraint?.isActive = false
            emptyUsernameDescriptionCenterYConstraint?.isActive = false
            userInfoDescriptionBottomSpace?.isActive = false
            emptyDescriptionUserInfoLabelBottomSpace?.isActive = false
            userInfoContainerBottomConstraint?.isActive = false
            return
        }

        configure(username)
        configure(clientName, isDescriptionHidden: isAggregator)
    }

    private func configure(_ provider: Provider) {
        provider.image.flatMap {
            bankIconView.kf.setImage(with: ImageResource(downloadURL: $0))
        }
        bankLabel.text = provider.displayName
    }

    private func configure(_ username: String?) {
        let isUsernameEmpty = username?.isEmpty ?? true

        userInfoLabel.text = username
        userInfoLabel.isHidden = isUsernameEmpty
        userInfoDescriptionTopConstraint?.isActive = !isUsernameEmpty
        emptyUsernameDescriptionCenterYConstraint?.isActive = isUsernameEmpty
    }

    private func configure(_ clientName: String, isDescriptionHidden: Bool) {
        userInfoDescription.isHidden = isDescriptionHidden
        emptyDescriptionUserInfoLabelBottomSpace?.isActive = isDescriptionHidden
        userInfoDescriptionBottomSpace?.isActive = !isDescriptionHidden

        let text = String(format: "%@ will obtain some of your financial information. Read More", clientName)
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
        userInfoDescription.linkTextAttributes = [
            NSAttributedString.Key.font: Font.bold(.micro),
            NSAttributedString.Key.foregroundColor: Color.accent
        ]
        userInfoDescription.attributedText = attributeText
        userInfoDescription.setLineHeight(lineHeight: 20)
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
