import Foundation

private class BundleLoadingClass {}

extension Bundle {
    static let tinkLinkUI = Bundle(url: Bundle(for: BundleLoadingClass.self).url(forResource: "Translations", withExtension: "bundle")!)!
    static let assetBundle = Bundle(url: Bundle(for: BundleLoadingClass.self).url(forResource: "Assets", withExtension: "bundle")!)!
}
