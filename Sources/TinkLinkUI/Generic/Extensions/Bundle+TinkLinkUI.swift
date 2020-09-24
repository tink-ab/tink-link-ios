import Foundation

extension Bundle {
    static let tinkLinkUI = Bundle(url: Bundle.module.url(forResource: "Translations", withExtension: "bundle")!)!
    static let assetBundle = Bundle.module.url(forResource: "Assets", withExtension: "bundle").flatMap(Bundle.init(url:)) ?? Bundle.module
}
