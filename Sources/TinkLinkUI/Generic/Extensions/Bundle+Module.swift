import Foundation

private class BundleLoadingClass {}

extension Bundle {
    static let module = Bundle(for: BundleLoadingClass.self)
}
