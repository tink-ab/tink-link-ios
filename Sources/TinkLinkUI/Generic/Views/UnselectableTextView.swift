import UIKit

// Taken from https://stackoverflow.com/a/44878203
final class UnselectableTextView: UITextView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard
            let position = closestPosition(to: point),
            let range = tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left))
        else { return false }

        let startIndex = offset(from: beginningOfDocument, to: range.start)

        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
