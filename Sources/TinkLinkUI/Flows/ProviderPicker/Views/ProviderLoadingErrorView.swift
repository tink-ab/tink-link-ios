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

        // TODO: REPLACE THIS
        iconView.image = UIImage(icon: .profile)
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

        retryButton.text = "Try again"
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

    func show(_ error: Error?) {
        textLabel.text = "We’re sorry, but we couldn't load any banks at the moment"
        descriptionLabel.text = "Please try again, or contact %@ if the problem persists."
        if let providerControllerError = error as? ProviderController.Error {
            retryButton.isHidden = false
        } else {
            retryButton.isHidden = true
        }
    }

    @objc private func retryButtonTapped() {
        delegate?.reloadProviderList(providerLoadingErrorView: self)
    }
}
