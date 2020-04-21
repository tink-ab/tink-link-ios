import UIKit

/// A type that can provide colors and fonts for Tink views.
public protocol AppearanceProviding {
    var colors: ColorProviding { get }
    var fonts: FontProviding { get }
}

/// A appearance provider that can provide colors and fonts for Tink views.
public struct AppearanceProvider: AppearanceProviding {
    /// Color provier
    public let colors: ColorProviding
    /// Font provier
    public let fonts: FontProviding

    /// Creates a customized Appearance with specific providers, if no value is passed, the default provider will be used.
    public init(
        colors: ColorProvider? = nil,
        fonts: FontProvider? = nil
    ) {
        self.colors = colors ?? ColorProvider()
        self.fonts = fonts ?? FontProvider()
    }
}
