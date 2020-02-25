import UIKit
import TinkLink

protocol AddCredentialFooterViewDelegate: AnyObject {
    func addCredentialFooterViewDidTapLink(_ addCredentialFooterView: AddCredentialFooterView, url: URL)
}

final class AddCredentialFooterView: UIView {
    weak var delegate: AddCredentialFooterViewDelegate?

    lazy var button: FloatingButton = {
        let button = FloatingButton()
        button.text = "Continue"
        return button
    }()
    lazy var bankIdAnotherDeviceButton: UIButton = {
        // TODO: handle using another deivce for BankID?
        let bankIdAnotherDeviceButton = UIButton()
        bankIdAnotherDeviceButton.setTitle("Open Mobile BankID on another device", for: .normal)
        bankIdAnotherDeviceButton.titleLabel?.font = Font.bold(.hecto)
        bankIdAnotherDeviceButton.setTitleColor(Color.accent, for: .normal)
        return bankIdAnotherDeviceButton
    }()
    private lazy var descriptionTextView: UITextView = {
        let descriptionTextView = UnselectableTextView()
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        descriptionTextView.clipsToBounds = false
        descriptionTextView.backgroundColor = Color.background
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
    private lazy var buttonBottomConstraint = stackView.topAnchor.constraint(equalTo: button.bottomAnchor)
    private var privacyPolicyRange: NSRange?
    private var termsAndConditionsRange: NSRange?
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)

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

    func updateButtonBottomConstraint(_ notification: KeyboardNotification) {
        let frameHeight = notification.frame.height
        buttonBottomConstraint.constant = frameHeight - stackView.bounds.height - safeAreaInsets.bottom
        buttonWidthConstraint.constant = frame.size.width
        button.rounded = false
        UIView.animate(withDuration: notification.duration) {
            self.layoutIfNeeded()
        }
    }

    func resetButtonBottomConstraint(_ notification: KeyboardNotification) {
        buttonBottomConstraint.constant = 0
        buttonWidthConstraint.constant = button.minimumWidth
        button.rounded = true
        UIView.animate(withDuration: notification.duration) {
            self.layoutIfNeeded()
        }
    }

    private func setup() {
        stackView.addArrangedSubview(descriptionTextView)
        addSubview(stackView)
        addSubview(button)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        bankIdAnotherDeviceButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            buttonWidthConstraint,
            button.heightAnchor.constraint(equalToConstant: 48),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),

            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonBottomConstraint,
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func configure(with provider: Provider, isAggregator: Bool) {
        switch provider.credentialKind {
        case .mobileBankID:
            button.text = "Open BankID"
            if ProcessInfo.processInfo.tinkEnableBankIDOnAnotherDevice, bankIdAnotherDeviceButton.superview == nil {
                stackView.insertArrangedSubview(bankIdAnotherDeviceButton, at: 0)
            }
        default:
            button.text = "Continue"
            if bankIdAnotherDeviceButton.superview != nil {
                bankIdAnotherDeviceButton.removeFromSuperview()
            }
        }
        descriptionTextView.isHidden = isAggregator
    }
}

extension AddCredentialFooterView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            if characterRange == termsAndConditionsRange || characterRange == privacyPolicyRange {
                delegate?.addCredentialFooterViewDidTapLink(self, url: URL)
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
}
