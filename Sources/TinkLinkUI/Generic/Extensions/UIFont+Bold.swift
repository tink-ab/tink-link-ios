import UIKit

extension UIFont {
    var bold: UIFont {
        guard let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return self
        }
        return UIFont(descriptor: boldFontDescriptor, size: pointSize)
    }
}
