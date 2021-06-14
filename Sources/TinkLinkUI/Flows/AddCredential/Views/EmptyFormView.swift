import UIKit

final class EmptyFormView: UIView {
    private let isAggregator: Bool
    private var formErrorView: FormTableViewErrorView?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let iconView = UIImageView()
    private let textLabel = UILabel()
    private let instructionView = UIView()
    private let instructionLabel = UILabel()
    private lazy var headerView = CredentialsHeaderView()

    private var contentViewHeightConstraint: NSLayoutConstraint?

    init(imageURL: URL?, text: String, isAggregator: Bool, errorText: String? = nil) {
        self.isAggregator = isAggregator
        if let errorText = errorText {
            self.formErrorView = FormTableViewErrorView(errorText: errorText)
        }
        super.init(frame: .zero)

        if let imageURL = imageURL {
            ImageLoader.shared.loadImage(at: imageURL) { [weak self] result in
                let image = try? result.get()
                self?.iconView.image = image
            }
        }
        let format = Strings.Credentials.description
        textLabel.text = String(format: format, text)

        setup(providerName: text)
    }

    init(image: UIImage?, text: String, isAggregator: Bool, errorText: String? = nil) {
        self.isAggregator = isAggregator
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

        if !isAggregator {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(headerView)
            NSLayoutConstraint.activate([
                headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }

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

            instructionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34).withPriority(.defaultHigh),
            instructionView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 34),
            instructionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -34).withPriority(.defaultHigh),
            instructionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            instructionView.widthAnchor.constraint(lessThanOrEqualToConstant: 460),
            contentViewCenterYConstraint,
            contentViewHeightConstraint
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentViewHeightConstraint?.constant = 0.27 * frame.height
    }
}
