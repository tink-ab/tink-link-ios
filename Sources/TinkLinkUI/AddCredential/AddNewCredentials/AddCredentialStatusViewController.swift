import UIKit

final class AddCredentialStatusViewController: UIViewController {
    private lazy var shadowLayer = CAShapeLayer()
    private lazy var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    private lazy var statusLabelView = UILabel()

    var status: String? {
        get {
            guard isViewLoaded else { return nil }
            return statusLabelView.text
        }
        set {
            guard isViewLoaded else { return }
            statusLabelView.text = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        shadowLayer.fillColor = UIColor(white: 0.0, alpha: 0.25).cgColor
        shadowLayer.fillRule = .evenOdd
        view.layer.addSublayer(shadowLayer)

        visualEffectView.layer.cornerRadius = 10
        visualEffectView.clipsToBounds = true
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)

        let stackView = UIStackView(arrangedSubviews: [activityIndicator, statusLabelView])
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 24, right: 24)
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(stackView)

        statusLabelView.font = UIFont.preferredFont(forTextStyle: .headline)
        statusLabelView.numberOfLines = 0
        statusLabelView.preferredMaxLayoutWidth = 220
        statusLabelView.textAlignment = .center

        activityIndicator.startAnimating()
        activityIndicator.setContentHuggingPriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            visualEffectView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            visualEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            statusLabelView.widthAnchor.constraint(equalToConstant: 240),

            stackView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        shadowLayer.frame = view.bounds

        let path = UIBezierPath(rect: view.bounds)
        path.append(UIBezierPath(roundedRect: visualEffectView.frame, cornerRadius: visualEffectView.layer.cornerRadius))

        shadowLayer.path = path.cgPath
    }
}
