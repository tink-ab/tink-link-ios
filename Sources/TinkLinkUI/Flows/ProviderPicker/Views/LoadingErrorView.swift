import UIKit

protocol LoadingErrorViewDelegate: AnyObject {
    func reloadProviderList(loadingErrorView: LoadingErrorView)
    func closeErrorView(loadingErrorView: LoadingErrorView)
}

final class LoadingErrorView: UIView {
    weak var delegate: LoadingErrorViewDelegate?

    private let stackView = UIStackView()
    private let iconBackgroundView = UIImageView()
    private let iconView = UIImageView()
    private let textLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let retryButton = FloatingButton()

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
        layoutMargins = .init(top: 32, left: 40, bottom: 32, right: 40)

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24

        iconView.image = UIImage(icon: .warning)?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Color.warning
        iconBackgroundView.layer.cornerRadius = 20
        iconBackgroundView.layer.backgroundColor = Color.warningBackground.cgColor

        textLabel.font = Font.subtitle1
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textColor = Color.label
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.setLineHeight(lineHeight: 20)

        descriptionLabel.font = Font.body1
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textColor = Color.secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setLineHeight(lineHeight: 20)

        cancelButton.setTitleColor(Color.button, for: .normal)
        cancelButton.titleLabel?.font = Font.subtitle1
        cancelButton.titleLabel?.adjustsFontForContentSizeCategory = true
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle(Strings.Generic.cancel, for: .normal)

        retryButton.text = Strings.Generic.retry
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(retryButton)
        addSubview(cancelButton)

        stackView.addArrangedSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconView)
        stackView.addArrangedSubview(textLabel)
        stackView.setCustomSpacing(6, after: textLabel)
        stackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 40),

            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),

            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            cancelButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),

            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    func configure(with error: Error?, showRetry: Bool) {
        textLabel.text = Strings.ProviderList.Error.title
        retryButton.isHidden = !showRetry
        if error is ProviderController.Error {
            descriptionLabel.text = Strings.ProviderList.Error.temporary
        } else {
            descriptionLabel.text = Strings.ProviderList.Error.description
        }
    }

    @objc private func retryButtonTapped() {
        delegate?.reloadProviderList(loadingErrorView: self)
    }

    @objc private func cancel() {
        delegate?.closeErrorView(loadingErrorView: self)
    }
}
