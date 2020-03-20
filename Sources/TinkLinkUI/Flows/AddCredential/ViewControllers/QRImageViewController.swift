import UIKit

protocol QRImageViewControllerDelegate: AnyObject {
    func qrImageViewControllerDidCancel(_ viewController: QRImageViewController)
}

final class QRImageViewController: UIViewController {
    private let imageContainerView = UIView()
    private let borderedCornersView = BorderedCornersView()
    private let imageView = UIImageView()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let stackView = UIStackView()

    weak var delegate: QRImageViewControllerDelegate?

    init(qrImage: UIImage) {
        imageView.image = qrImage

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        navigationItem.title = "Supplemental Information"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))

        view.backgroundColor = Color.background

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        borderedCornersView.tintColor = Color.separator
        borderedCornersView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = Font.semibold(.mega)
        subtitleLabel.textColor = Color.label
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Open the BankID app"
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.font = Font.regular(.deci)
        descriptionLabel.textColor = Color.label
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Open the Mobile Bank ID app and scan this QR code to authenticate"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        stackView.addArrangedSubview(imageContainerView)
        stackView.setCustomSpacing(32, after: imageContainerView)
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(borderedCornersView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 172),
            imageView.widthAnchor.constraint(equalToConstant: 172),
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            borderedCornersView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            borderedCornersView.topAnchor.constraint(equalTo: imageView.topAnchor),
            borderedCornersView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            borderedCornersView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }

    @objc private func cancelButtonPressed() {
        delegate?.qrImageViewControllerDidCancel(self)
    }
}
