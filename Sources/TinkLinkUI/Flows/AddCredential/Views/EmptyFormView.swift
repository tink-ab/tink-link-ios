import UIKit
import Kingfisher

final class EmptyFormView: UIView {
    private var formErrorView: FormTableViewErrorView?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let iconView = UIImageView()
    private let textLabel = UILabel()
    private let instructionView = UIView()
    private let instructionLabel = UILabel()

    private var contentViewHeightConstraint: NSLayoutConstraint?

    init(imageURL: URL?, text: String, errorText: String? = nil) {
        if let errorText = errorText {
            self.formErrorView = FormTableViewErrorView(errorText: errorText)
        }
        super.init(frame: .zero)

        iconView.kf.setImage(with: imageURL)
        let format = Strings.Credentials.description
        textLabel.text = String(format: format, text)

        setup(providerName: text)
    }

    init(image: UIImage?, text: String, errorText: String? = nil) {
        if let errorText = errorText {
            self.formErrorView = FormTableViewErrorView(errorText: errorText)
        }
        super.init(frame: .zero)

        iconView.image = image
        let format = Strings.Credentials.description
        textLabel.text = String(format: format, text)

        setup(providerName: text)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(providerName: String) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        instructionView.backgroundColor = Color.accentBackground
        instructionView.layer.cornerRadius = 12
        instructionView.translatesAutoresizingMaskIntoConstraints = false

        instructionLabel.numberOfLines = 0
        instructionLabel.font = Font.body2
        instructionLabel.adjustsFontForContentSizeCategory = true
        instructionLabel.textColor = Color.label

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 16
        paragraphStyle.headIndent = 22

        let instructionText = String(format: Strings.Credentials.instructions, providerName)

        let attributedString = NSMutableAttributedString(string: instructionText, attributes: [.paragraphStyle: paragraphStyle, .font: Font.body2])
        if let regex = try? NSRegularExpression(pattern: "[0-9].", options: []) {
            let range = NSRange(location: 0, length: attributedString.length)
            let matches = regex.matches(in: attributedString.string, options: [], range: range)
            matches.forEach {
                attributedString.addAttributes([.font: Font.subtitle1, .kern: 2.1], range: $0.range)
            }
        }

        instructionLabel.attributedText = attributedString
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        textLabel.font = Font.subtitle1
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(iconView)
        contentView.addSubview(textLabel)
        contentView.addSubview(instructionView)
        instructionView.addSubview(instructionLabel)

        if let formErrorView = formErrorView {
            formErrorView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(formErrorView)
            NSLayoutConstraint.activate([
                formErrorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                formErrorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                formErrorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                formErrorView.bottomAnchor.constraint(lessThanOrEqualTo: iconView.topAnchor, constant: -4)
            ])
        }

        let contentViewCenterYConstraint = instructionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 12)
        contentViewCenterYConstraint.priority = .defaultLow
        let contentViewHeightConstraint = contentView.bottomAnchor.constraint(greaterThanOrEqualTo: instructionView.bottomAnchor, constant: 120)
        self.contentViewHeightConstraint = contentViewHeightConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34),
            textLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -34),

            instructionLabel.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 24),
            instructionLabel.topAnchor.constraint(equalTo: instructionView.topAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -24),
            instructionLabel.bottomAnchor.constraint(equalTo: instructionView.bottomAnchor, constant: -24),

            instructionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34),
            instructionView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 34),
            instructionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -34),
            contentViewCenterYConstraint,
            contentViewHeightConstraint
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentViewHeightConstraint?.constant = 0.27 * frame.height
    }
}
