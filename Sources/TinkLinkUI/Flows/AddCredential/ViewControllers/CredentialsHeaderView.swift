import UIKit

final class CredentialsHeaderView: UIView {
    private lazy var tinkIconView: UIImageView = {
        let tinkIconView = UIImageView()
        tinkIconView.image = UIImage(icon: .tink)
        tinkIconView.contentMode = .scaleAspectFit
        return tinkIconView
    }()

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
        backgroundColor = Color.background
        layoutMargins = .init(top: 18, left: 18, bottom: 8, right: 18)

        tinkIconView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tinkIconView)

        NSLayoutConstraint.activate([
            tinkIconView.widthAnchor.constraint(equalToConstant: 40),
            tinkIconView.heightAnchor.constraint(equalToConstant: 20),
            tinkIconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            tinkIconView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            tinkIconView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
}
