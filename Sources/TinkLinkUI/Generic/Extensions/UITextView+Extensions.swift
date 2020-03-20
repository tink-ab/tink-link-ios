import UIKit

extension UITextView {
    func setLineHeight(lineHeight: CGFloat) {
        guard let font = font else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = max(lineHeight - font.lineHeight, 0)
        paragraphStyle.alignment = textAlignment

        let attrString: NSMutableAttributedString
        if let attributedText = attributedText {
            attrString = NSMutableAttributedString(attributedString: attributedText)
        } else {
            attrString = NSMutableAttributedString(string: text ?? "")
            attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrString.length))
        }

        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        self.attributedText = attrString
    }
}
