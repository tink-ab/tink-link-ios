import UIKit

protocol ProviderLoadingErrorViewDelegate: AnyObject {
    func reloadProviderList(providerLoadingErrorView: ProviderLoadingErrorView)
}

final class ProviderLoadingErrorView: UIView {
    weak var delegate: ProviderLoadingErrorViewDelegate?

    private let stackView = UIStackView()
    private let iconBackgroundView = UIImageView()
    private let iconView = UIImageView()
    private let textLabel =  UILabel()
    private let descriptionLabel =  UILabel()
    private let retryButton = FloatingButton()

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
        layoutMargins = .init(top: 32, left: 40, bottom: 32, right: 40)

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24

        iconView.image = UIImage(icon: .warning)?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Color.warning
        iconBackgroundView.layer.cornerRadius = 32
        iconBackgroundView.layer.backgroundColor = Color.warningBackground.cgColor

        textLabel.font = Font.semibold(.mega)
        textLabel.textColor = Color.label
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0

        descriptionLabel.font = Font.regular(.hecto)
        descriptionLabel.textColor = Color.secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        retryButton.text = NSLocalizedString("ProviderPicker.Error.RetryButton", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Try again", comment: "Title for button to try loading providers again.")
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(retryButton)

        stackView.addArrangedSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconView)
        stackView.addArrangedSubview(textLabel)
        stackView.setCustomSpacing(16, after: textLabel)
        stackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            iconBackgroundView.widthAnchor.constraint(equalToConstant: 64),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 64),

            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),

            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    func configure(with error: Error?) {
        textLabel.text = NSLocalizedString("ProviderPicker.Error.Title", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "We’re sorry, but we couldn't load any banks at the moment", comment: "Title for when providers could not be loaded.")
        if error is ProviderController.Error {
            descriptionLabel.text = NSLocalizedString("ProviderPicker.Error.Temporary", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "This could be a temporary error, please try again and see if the problem persists.", comment: "Description for error when providers could not be loaded and it is likely it's a temporary error.")
            retryButton.isHidden = false
        } else {
            descriptionLabel.text = NSLocalizedString("ProviderPicker.Error.Description", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "We are informed of this error and are working hard to resolve it. Bear with us, and try again a bit later.", comment: "Description for error when providers could not be loaded.")
            retryButton.isHidden = true
        }
    }

    @objc private func retryButtonTapped() {
        delegate?.reloadProviderList(providerLoadingErrorView: self)
    }
}
