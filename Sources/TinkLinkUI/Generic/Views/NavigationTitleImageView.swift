import UIKit
import Kingfisher

final class NavigationTitleImageView: UIView {
    private let navigationTitleLabel = UILabel()
    private let navigationTitleImageView = UIImageView()
    private let providerTagLabel = ProviderTagView()

    private var trailingTitleConstraint: NSLayoutConstraint!
    private var trailingBetaConstraint: NSLayoutConstraint!

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

        providerTagLabel.translatesAutoresizingMaskIntoConstraints = false
        providerTagLabel.isHidden = true

        addSubview(navigationTitleImageView)
        addSubview(navigationTitleLabel)
        addSubview(providerTagLabel)

        trailingTitleConstraint = navigationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingBetaConstraint = providerTagLabel.trailingAnchor.constraint(equalTo: trailingAnchor)

        NSLayoutConstraint.activate([
            navigationTitleImageView.widthAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.heightAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationTitleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationTitleImageView.trailingAnchor, constant: 8),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingTitleConstraint,

            providerTagLabel.leadingAnchor.constraint(equalTo: navigationTitleLabel.trailingAnchor, constant: 8),
            providerTagLabel.firstBaselineAnchor.constraint(equalTo: navigationTitleLabel.firstBaselineAnchor)
        ])
    }

    func setProviderTagLabelHidden(_ hidden: Bool, kind: ProviderTag = .beta) {
        providerTagLabel.isHidden = hidden
        providerTagLabel.providerTag = kind
        trailingTitleConstraint.isActive = hidden
        trailingBetaConstraint.isActive = !hidden
    }
}
