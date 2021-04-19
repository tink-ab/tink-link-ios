import UIKit
import Kingfisher

final class NavigationTitleImageView: UIView {
    private let navigationTitleLabel = UILabel()
    private let navigationTitleImageView = UIImageView()
    private let providerTagLabel = ProviderTagView()

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
        setProviderTags(demo: false, beta: false)
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

        addSubview(navigationTitleImageView)
        addSubview(navigationTitleLabel)
        addSubview(providerTagLabel)

        trailingTitleConstraint = navigationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingTagConstraint = providerTagLabel.trailingAnchor.constraint(equalTo: trailingAnchor)

        NSLayoutConstraint.activate([
            navigationTitleImageView.widthAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.heightAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationTitleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationTitleImageView.trailingAnchor, constant: 8),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingTitleConstraint,

            providerTagLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            providerTagLabel.firstBaselineAnchor.constraint(equalTo: navigationTitleLabel.firstBaselineAnchor),
            providerTagLabel.leadingAnchor.constraint(equalTo: navigationTitleLabel.trailingAnchor, constant: 8),
        ])
    }

    func setProviderTags(demo: Bool, beta: Bool) {
        if demo == true && beta == true {
            providerTagLabel.providerTag = .demoAndBeta
        } else if demo == true {
            providerTagLabel.providerTag = .demo
        } else if beta == true {
            providerTagLabel.providerTag = .beta
        }

        providerTagLabel.isHidden = !(demo || beta)
        trailingTitleConstraint.isActive = !(demo || beta)
        trailingTagConstraint.isActive = (demo || beta)
    }
}
