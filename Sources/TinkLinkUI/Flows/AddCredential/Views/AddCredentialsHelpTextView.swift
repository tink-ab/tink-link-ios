import UIKit
import Down

final class AddCredentialsHelpTextView: UIView {
    private let helpTextView = UnselectableTextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        directionalLayoutMargins = .init(top: 16, leading: 24, bottom: 16, trailing: 24)

        helpTextView.linkTextAttributes = [
            NSAttributedString.Key.font: Font.footnote.bold,
            NSAttributedString.Key.foregroundColor: Color.accent
        ]

        helpTextView.textContainer.lineFragmentPadding = 0
        helpTextView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        helpTextView.backgroundColor = .clear
        helpTextView.isScrollEnabled = false
        helpTextView.isEditable = false
        helpTextView.adjustsFontForContentSizeCategory = true

        let containerView = UIView()
        containerView.backgroundColor = Color.accentBackground
        containerView.layer.cornerRadius = 4

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(helpTextView)
        helpTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            helpTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            helpTextView.topAnchor.constraint(equalTo: containerView.topAnchor),
            helpTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            helpTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    func configure(markdownString: String) {
        let markdown = Down(markdownString: markdownString)
        guard let attributedString = try? markdown.toAttributedString() else {
            helpTextView.text = markdownString
            return
        }

        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

        mutableAttributedString.addAttributes([.font: Font.footnote, .foregroundColor: Color.secondaryLabel], range: NSRange(location: 0, length: attributedString.length))

        // There can be an extra newline in the end of the
        // string (Down doing this?) so we need to remove it.
        let lastCharRange = NSRange(location: mutableAttributedString.length - 1, length: 1)
        if mutableAttributedString.string.hasSuffix("\n") {
            mutableAttributedString.deleteCharacters(in: lastCharRange)
        }
        helpTextView.attributedText = mutableAttributedString
        helpTextView.setLineHeight(lineHeight: 20)
    }
}
