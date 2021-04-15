import UIKit
import Kingfisher

final class NavigationTitleImageView: UIView {
    private let navigationTitleLabel = UILabel()
    private let navigationTitleImageView = UIImageView()
    private let betaLabel = ProviderTagView()
    private let demoLabel = ProviderTagView()

    private var trailingTitleConstraint: NSLayoutConstraint!
    private var trailingTagConstraint: NSLayoutConstraint!

    init(imageURL: URL?, text: String) {
        super.init(frame: .zero)

        navigationTitleImageView.kf.setImage(with: imageURL)
        navigationTitleLabel.text = text
        setup()
    }

    init(image: UIImage?, text: String) {
        super.init(frame: .zero)

        navigationTitleImageView.image = image
        navigationTitleLabel.text = text
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        navigationTitleLabel.textColor = Color.navigationBarLabel
        navigationTitleLabel.font = Font.subtitle1
        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        navigationTitleImageView.contentMode = .scaleAspectFit
        navigationTitleImageView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [betaLabel, demoLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(navigationTitleImageView)
        addSubview(navigationTitleLabel)
        addSubview(stackView)

        trailingTitleConstraint = navigationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingTagConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)

        NSLayoutConstraint.activate([
            navigationTitleImageView.widthAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.heightAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationTitleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationTitleImageView.trailingAnchor, constant: 8),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingTitleConstraint,

            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.firstBaselineAnchor.constraint(equalTo: navigationTitleLabel.firstBaselineAnchor),
            stackView.leadingAnchor.constraint(equalTo: navigationTitleLabel.trailingAnchor, constant: 8)
        ])
    }

    func setBetaTagLabel(_ visible: Bool) {
        betaLabel.providerTag = ProviderTag.beta
        betaLabel.isHidden = !visible
        trailingTitleConstraint.isActive = !visible
        trailingTagConstraint.isActive = visible
    }

    func setDemoTagLabel(_ visible: Bool) {
        demoLabel.providerTag = ProviderTag.demo
        demoLabel.isHidden = !visible
        trailingTitleConstraint.isActive = !visible
        trailingTagConstraint.isActive = visible
    }
}
