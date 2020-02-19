import UIKit

final class QRImageViewController: UIViewController {
    private let imageView = UIImageView()
    private let closeButton = UIButton(type: .system)

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
        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.separator

        closeButton.backgroundColor = Color.background
        closeButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(separatorLine)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),

            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
