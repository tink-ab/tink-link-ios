import UIKit
import Kingfisher

final class EmptyFormView: UIView {
    private var formErrorView: FormTableViewErrorView?

    private let iconView = UIImageView()
    private let textLabel = UILabel()

    init(imageURL: URL?, text: String, errorText: String? = nil) {
        if let errorText = errorText {
            self.formErrorView = FormTableViewErrorView(errorText: errorText)
        }
        super.init(frame: .zero)

        iconView.kf.setImage(with: imageURL)
        let format = Strings.Credentials.description
        textLabel.text = String(format: format, text)
        setup()
    }

    init(image: UIImage?, text: String, errorText: String? = nil) {
        if let errorText = errorText {
            self.formErrorView = FormTableViewErrorView(errorText: errorText)
        }
        super.init(frame: .zero)

        iconView.image = image
        let format = Strings.Credentials.description
        textLabel.text = String(format: format, text)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        textLabel.font = Font.headline
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(textLabel)

        if let formErrorView = formErrorView {
            formErrorView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(formErrorView)
            NSLayoutConstraint.activate([
                formErrorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                formErrorView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 16),
                formErrorView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),

            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            textLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
