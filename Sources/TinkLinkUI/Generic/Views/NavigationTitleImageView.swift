import UIKit

final class NavigationTitleImageView: UIView {
    private let navigationTitleLabel = UILabel()
    private let navigationTitleImageView = UIImageView()
    private let demoTagLabel = DemoTagView()

    private var trailingTitleConstraint: NSLayoutConstraint?
    private var trailingTagConstraint: NSLayoutConstraint?

    init(imageURL: URL?, text: String) {
        super.init(frame: .zero)

        if let imageURL = imageURL {
            ImageLoader.shared.loadImage(at: imageURL) { [weak self] result in
                let image = try? result.get()
                self?.navigationTitleImageView.image = image
            }
        }

        navigationTitleLabel.text = text
        setup()
    }

    init(image: UIImage?, text: String) {
        super.init(frame: .zero)

        navigationTitleImageView.image = image
        navigationTitleLabel.text = text
        setup()
        setDemoTagHidden(true)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        navigationTitleLabel.textColor = Color.navigationBarLabel
        navigationTitleLabel.font = Font.subtitle1
        navigationTitleLabel.adjustsFontForContentSizeCategory = true
        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        navigationTitleImageView.contentMode = .scaleAspectFit
        navigationTitleImageView.translatesAutoresizingMaskIntoConstraints = false

        demoTagLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(navigationTitleImageView)
        addSubview(navigationTitleLabel)
        addSubview(demoTagLabel)

        let trailingTitleConstraint: NSLayoutConstraint
        trailingTitleConstraint = navigationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        self.trailingTitleConstraint = trailingTitleConstraint
        trailingTagConstraint = demoTagLabel.trailingAnchor.constraint(equalTo: trailingAnchor)

        NSLayoutConstraint.activate([
            navigationTitleImageView.widthAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.heightAnchor.constraint(equalToConstant: 20),
            navigationTitleImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationTitleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationTitleImageView.trailingAnchor, constant: 8),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingTitleConstraint,

            demoTagLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            demoTagLabel.firstBaselineAnchor.constraint(equalTo: navigationTitleLabel.firstBaselineAnchor),
            demoTagLabel.leadingAnchor.constraint(equalTo: navigationTitleLabel.trailingAnchor, constant: 8),
        ])
    }

    func setDemoTagHidden(_ hidden: Bool) {
        demoTagLabel.isHidden = hidden
        trailingTitleConstraint?.isActive = hidden
        trailingTagConstraint?.isActive = !hidden
    }
}
