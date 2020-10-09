import UIKit
import Down

final class ProviderHelpTextView: UIView {
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
        directionalLayoutMargins = .init(top: 0, leading: 24, bottom: 12, trailing: 24)

        helpTextView.linkTextAttributes = [
            NSAttributedString.Key.font: Font.footnote,
            NSAttributedString.Key.foregroundColor: Color.secondaryLabel
        ]

        helpTextView.textContainer.lineFragmentPadding = 0
        helpTextView.textContainerInset = .zero
        helpTextView.backgroundColor = .clear
        helpTextView.isScrollEnabled = false
        helpTextView.isEditable = false
        helpTextView.adjustsFontForContentSizeCategory = true

        addSubview(helpTextView)
        helpTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            helpTextView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            helpTextView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            helpTextView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            helpTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
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
