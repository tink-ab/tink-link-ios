import UIKit
import TinkLinkSDK

protocol AddCredentialFooterViewDelegate: AnyObject {
    func addCredentialFooterViewDidTapTermsAndConditions(_ addCredentialFooterView: AddCredentialFooterView, url: URL)
    func addCredentialFooterViewDidTapPrivacyPolicy(_ addCredentialFooterView: AddCredentialFooterView, url: URL)
}

final class AddCredentialFooterView: UIView {
    weak var delegate: AddCredentialFooterViewDelegate?

    lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Font.semibold(.hecto)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(Color.background, for: .normal)
        button.backgroundColor = Color.accent
        button.contentEdgeInsets = .init(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    private lazy var bankIdAnotherDeviceButton: UIButton = {
        // TODO: handle using another deivce for BankID?
        let bankIdAnotherDeviceButton = UIButton()
        bankIdAnotherDeviceButton.setTitle("Open Mobile BankID on another device", for: .normal)
        bankIdAnotherDeviceButton.titleLabel?.font = Font.bold(.hecto)
        bankIdAnotherDeviceButton.setTitleColor(Color.accent, for: .normal)
        return bankIdAnotherDeviceButton
    }()
    private lazy var descriptionTextView: UITextView = {
        let descriptionTextView = UITextView()
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        descriptionTextView.font = Font.regular(.micro)
        descriptionTextView.linkTextAttributes = [
            .foregroundColor: Color.secondaryLabel,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let text = "By using the service, you agree to Tink’s Terms and Conditions and Privacy Policy"
        let attributeText = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: Color.secondaryLabel])
        let languageCode = Locale.current.languageCode ?? ""
        let privacyPolicyUrl = URL(string: "https://link.tink.com/privacy-policy/\(languageCode)")!
        let privacyPolicyText = "Privacy Policy"
        let privacyPolicyRange = attributeText.mutableString.range(of: privacyPolicyText)
        self.privacyPolicyRange = privacyPolicyRange
        attributeText.addAttributes([.link: privacyPolicyUrl,], range: privacyPolicyRange)
        let termsAndConditionsText = "Terms and Conditions"
        let termsAndConditionsUrl = URL(string: "https://link.tink.com/terms-and-conditions/\(languageCode)")!
        let termsAndConditionsRange = attributeText.mutableString.range(of: termsAndConditionsText)
        self.termsAndConditionsRange = termsAndConditionsRange
        attributeText.addAttributes([.link: termsAndConditionsUrl], range: termsAndConditionsRange)
        descriptionTextView.attributedText = attributeText
        return descriptionTextView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    private var buttonBottomConstraint: NSLayoutConstraint?
    private var privacyPolicyRange: NSRange?
    private var termsAndConditionsRange: NSRange?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        button.layer.cornerRadius = button.frame.height / 2
    }

    func updateButtonBottomConstraint(_ frameHeight: CGFloat) {
        buttonBottomConstraint?.constant = frameHeight - stackView.frame.height - stackView.layoutMargins.top
    }

    func resetButtonBottomConstraint() {
        buttonBottomConstraint?.constant = 0
    }

    private func setup() {
        addSubview(button)
        addSubview(stackView)
        stackView.addArrangedSubview(descriptionTextView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        bankIdAnotherDeviceButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        let buttonBottomConstraint = stackView.topAnchor.constraint(equalTo: button.bottomAnchor)
        self.buttonBottomConstraint = buttonBottomConstraint
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),

            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonBottomConstraint,
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with provider: Provider) {
        switch provider.credentialKind {
        case .mobileBankID:
            button.setTitle("Open BankID", for: .normal)
            if bankIdAnotherDeviceButton.superview == nil {
                stackView.insertArrangedSubview(bankIdAnotherDeviceButton, at: 0)
            }
        default:
            button.setTitle("Continue", for: .normal)
            if bankIdAnotherDeviceButton.superview != nil {
                bankIdAnotherDeviceButton.removeFromSuperview()
            }
        }
    }
}

extension AddCredentialFooterView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            if characterRange == termsAndConditionsRange {
                delegate?.addCredentialFooterViewDidTapTermsAndConditions(self, url: URL)
                return false
            } else if characterRange == privacyPolicyRange {
                delegate?.addCredentialFooterViewDidTapPrivacyPolicy(self, url: URL)
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
}
