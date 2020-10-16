import UIKit
import TinkLink
import Kingfisher

protocol AddCredentialsHeaderViewDelegate: AnyObject {
    func addCredentialsHeaderViewDidTapReadMore(_ addCredentialsHeaderView: AddCredentialsHeaderView)
}

final class AddCredentialsHeaderView: UIView {
    private lazy var bankIconView: UIImageView = {
        let bankIconView = UIImageView()
        bankIconView.contentMode = .scaleAspectFit
        return bankIconView
    }()

    private lazy var tinkIconView: UIImageView = {
        let tinkIconView = UIImageView()
        tinkIconView.image = UIImage(icon: .tink)
        tinkIconView.contentMode = .scaleAspectFit
        return tinkIconView
    }()

    private lazy var bankLabel: UILabel = {
        let bankLabel = UILabel()
        bankLabel.font = Font.headline
        bankLabel.adjustsFontForContentSizeCategory = true
        bankLabel.textColor = Color.label
        bankLabel.numberOfLines = 0
        return bankLabel
    }()

    private let userInfoContainerView = UIView()
    private let userInfoIconBackgroundView: UIView = {
        let userInfoIconBackgroundView = UIView()
        userInfoIconBackgroundView.backgroundColor = Color.accent.withAlphaComponent(0.1)
        userInfoIconBackgroundView.layer.cornerRadius = 20

        return userInfoIconBackgroundView
    }()

    private let userInfoIconView: UIImageView = {
        let userInfoIconView = UIImageView()
        userInfoIconView.tintColor = Color.accent
        userInfoIconView.image = UIImage(icon: .profile)?.withRenderingMode(.alwaysTemplate)
        return userInfoIconView
    }()

    private lazy var userInfoDescription: UITextView = {
        let userInfoDescription = UnselectableTextView()
        userInfoDescription.textContainerInset = .zero
        userInfoDescription.textContainer.lineFragmentPadding = 0
        userInfoDescription.font = Font.footnote
        userInfoDescription.textColor = Color.label
        userInfoDescription.isScrollEnabled = false
        userInfoDescription.backgroundColor = .clear
        userInfoDescription.isEditable = false
        userInfoDescription.clipsToBounds = false
        userInfoDescription.adjustsFontForContentSizeCategory = true
        userInfoDescription.delegate = self
        userInfoDescription.setLineHeight(lineHeight: 20)
        return userInfoDescription
    }()

    private lazy var dashLine: UIView = {
        let dashLine = UIView()
        dashLine.backgroundColor = .clear
        dashLine.layer.addSublayer(dashLayer)

        dashLayer.frame = CGRect(origin: dashLine.bounds.origin, size: CGSize(width: 1, height: 20))

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 20))
        dashLayer.path = path

        return dashLine
    }()

    private lazy var dashLayer: CAShapeLayer = {
        let dashLayer = CAShapeLayer()
        dashLayer.fillColor = UIColor.clear.cgColor
        dashLayer.strokeColor = UIColor.darkGray.cgColor
        dashLayer.lineWidth = 1
        dashLayer.lineDashPattern = [1, 3]
        return dashLayer
    }()

    private var readMoreRange: NSRange?

    private var userInfoDescriptionBottomSpace: NSLayoutConstraint?
    private var userInfoDescriptionTopConstraint: NSLayoutConstraint?
    private var userInfoEmptyBottomConstraint: NSLayoutConstraint?
    private var emptyUserInfoContainerBottomConstraint: NSLayoutConstraint?
    private var userInfoContainerBottomConstraint: NSLayoutConstraint?

    weak var delegate: AddCredentialsHeaderViewDelegate?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = Color.accentBackground
        layoutMargins = .init(top: 24, left: 24, bottom: 24, right: 24)

        bankLabel.translatesAutoresizingMaskIntoConstraints = false
        bankIconView.translatesAutoresizingMaskIntoConstraints = false
        tinkIconView.translatesAutoresizingMaskIntoConstraints = false
        userInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        dashLine.translatesAutoresizingMaskIntoConstraints = false
        userInfoIconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        userInfoIconView.translatesAutoresizingMaskIntoConstraints = false
        userInfoDescription.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bankLabel)
        addSubview(bankIconView)
        addSubview(tinkIconView)
        addSubview(userInfoContainerView)

        userInfoContainerView.addSubview(dashLine)
        userInfoContainerView.addSubview(userInfoIconBackgroundView)
        userInfoContainerView.addSubview(userInfoIconView)
        userInfoContainerView.addSubview(userInfoDescription)

        let userInfoDescriptionTopConstraint = userInfoDescription.topAnchor.constraint(equalTo: lastBaselineAnchor, constant: 8)
        self.userInfoDescriptionTopConstraint = userInfoDescriptionTopConstraint

        let userInfoDescriptionBottomSpace = userInfoDescription.bottomAnchor.constraint(equalTo: userInfoContainerView.bottomAnchor)
        self.userInfoDescriptionBottomSpace = userInfoDescriptionBottomSpace

        let userInfoContainerBottomConstraint = userInfoContainerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        self.userInfoContainerBottomConstraint = userInfoContainerBottomConstraint
        emptyUserInfoContainerBottomConstraint = bankIconView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            bankIconView.widthAnchor.constraint(equalToConstant: 40),
            bankIconView.heightAnchor.constraint(equalToConstant: 40),
            bankIconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            bankIconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            bankIconView.trailingAnchor.constraint(equalTo: bankLabel.leadingAnchor, constant: -10),

            tinkIconView.widthAnchor.constraint(equalToConstant: 40),
            tinkIconView.heightAnchor.constraint(equalToConstant: 20),
            tinkIconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            tinkIconView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            bankLabel.centerYAnchor.constraint(equalTo: bankIconView.centerYAnchor),
            bankLabel.trailingAnchor.constraint(equalTo: tinkIconView.leadingAnchor),

            userInfoContainerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            userInfoContainerView.topAnchor.constraint(equalTo: bankIconView.bottomAnchor),
            userInfoContainerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            userInfoContainerBottomConstraint,

            dashLine.topAnchor.constraint(equalTo: userInfoContainerView.topAnchor),
            dashLine.heightAnchor.constraint(equalToConstant: 20),
            dashLine.widthAnchor.constraint(equalToConstant: 1),
            dashLine.centerXAnchor.constraint(equalTo: bankIconView.centerXAnchor),
            dashLine.bottomAnchor.constraint(equalTo: userInfoIconBackgroundView.topAnchor),

            userInfoIconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            userInfoIconBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            userInfoIconBackgroundView.centerYAnchor.constraint(equalTo: userInfoIconView.centerYAnchor),
            userInfoIconBackgroundView.centerXAnchor.constraint(equalTo: userInfoIconView.centerXAnchor),
            userInfoIconView.widthAnchor.constraint(equalToConstant: 24),
            userInfoIconView.heightAnchor.constraint(equalToConstant: 24),
            userInfoIconView.centerXAnchor.constraint(equalTo: dashLine.centerXAnchor),

            userInfoDescription.leadingAnchor.constraint(equalTo: userInfoIconBackgroundView.trailingAnchor, constant: 10),
            userInfoDescription.centerYAnchor.constraint(equalTo: userInfoIconView.centerYAnchor),
            userInfoDescription.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor)
        ])
    }

    func configure(with provider: Provider, clientName: String, isAggregator: Bool) {
        configure(provider)

        let shouldHideUserInfoContainer = isAggregator
        guard !shouldHideUserInfoContainer else {
            userInfoContainerView.isHidden = true
            emptyUserInfoContainerBottomConstraint?.isActive = true

            userInfoDescriptionTopConstraint?.isActive = false
            userInfoDescriptionBottomSpace?.isActive = false
            userInfoContainerBottomConstraint?.isActive = false
            return
        }

        configure(clientName, isDescriptionHidden: isAggregator)
    }

    private func configure(_ provider: Provider) {
        if let image = provider.image {
            bankIconView.kf.setImage(with: ImageResource(downloadURL: image))
        }
        bankLabel.text = provider.displayName
    }

    private func configure(_ clientName: String, isDescriptionHidden: Bool) {
        userInfoDescription.isHidden = isDescriptionHidden
        userInfoDescriptionBottomSpace?.isActive = !isDescriptionHidden

        let readMoreFormat = Strings.Credentials.consentText
        let text = String(format: readMoreFormat, clientName)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.label,
            .font: Font.footnote
        ]
        let attributeText = NSMutableAttributedString(string: text, attributes: attributes)
        let readMoreText = Strings.Credentials.readMore
        let readMoreRange = attributeText.mutableString.range(of: readMoreText)
        self.readMoreRange = readMoreRange
        attributeText.addAttributes([
            NSAttributedString.Key.font: Font.footnote.bold,
            NSAttributedString.Key.foregroundColor: Color.accent,
            NSAttributedString.Key.link: "",
        ], range: readMoreRange)
        userInfoDescription.linkTextAttributes = [
            NSAttributedString.Key.font: Font.footnote.bold,
            NSAttributedString.Key.foregroundColor: Color.accent
        ]
        userInfoDescription.attributedText = attributeText
        userInfoDescription.setLineHeight(lineHeight: 20)
    }
}

extension AddCredentialsHeaderView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            if characterRange == readMoreRange {
                delegate?.addCredentialsHeaderViewDidTapReadMore(self)
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
}
