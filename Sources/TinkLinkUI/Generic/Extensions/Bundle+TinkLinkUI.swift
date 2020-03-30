import Foundation

private class BundleLoadingClass { }

extension Bundle {
    static let tinkLinkUI = Bundle(for: BundleLoadingClass.self)
}
