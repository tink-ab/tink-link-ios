import UIKit
import TinkLinkSDK

final class AddCredentialFooterView: UIView {
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
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Font.regular(.micro)
        descriptionLabel.textColor = Color.secondaryLabel
        descriptionLabel.numberOfLines = 0
        let text = "By using the service, you agree to Tink’s Terms and Conditions and Privacy Policy"
        let attributeText = NSMutableAttributedString(string: text)
        let privacyPolicyText = "Privacy Policy"
        let privacyPolicyRange = attributeText.mutableString.range(of: privacyPolicyText)
        attributeText.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ], range: privacyPolicyRange)
        let termsAndConditionsText = "Terms and Conditions"
        let termsAndConditionsRange = attributeText.mutableString.range(of: termsAndConditionsText)
        attributeText.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ], range: termsAndConditionsRange)
        descriptionLabel.attributedText = attributeText
        return descriptionLabel
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()

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

    private func setup() {
        addSubview(button)
        addSubview(stackView)
        stackView.addArrangedSubview(descriptionLabel)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        bankIdAnotherDeviceButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),

            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: button.bottomAnchor),
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
