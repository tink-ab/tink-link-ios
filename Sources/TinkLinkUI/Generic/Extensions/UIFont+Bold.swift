import UIKit

extension UIFont {
    var bold: UIFont {
        guard let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return self
        }
        return UIFont(descriptor: boldFontDescriptor, size: pointSize)
    }

    var smallCaps: UIFont {
        let lowerCaseFeatureSetting: [UIFontDescriptor.FeatureKey: Any] = [
            .featureIdentifier: kLowerCaseType,
            .typeIdentifier: kLowerCaseSmallCapsSelector
        ]
        let upperCaseFeatureSetting: [UIFontDescriptor.FeatureKey: Any] = [
            .featureIdentifier: kUpperCaseType,
            .typeIdentifier: kUpperCaseSmallCapsSelector
        ]
        let smallCapsFontDescriptor = fontDescriptor.addingAttributes([.featureSettings: [lowerCaseFeatureSetting, upperCaseFeatureSetting]])
        return UIFont(descriptor: smallCapsFontDescriptor, size: pointSize)
    }
}
