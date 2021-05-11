import UIKit

// Stackoverflow: https://stackoverflow.com/questions/48176121/adjustsfontforcontentsizecategory-in-uilabel-with-attributed-text
extension NSMutableAttributedString {
    func setFont(_ font: UIFont) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: string.count))
        return self
    }
}
