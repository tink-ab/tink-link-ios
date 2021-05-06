import UIKit

// Taken from https://stackoverflow.com/a/50369557
// Make the text not selectable but also support voice over
final class UnselectableTextView: UITextView {
    override public var selectedTextRange: UITextRange? {
        get { return nil }
        set {}
    }
}
