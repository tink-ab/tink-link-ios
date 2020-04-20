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

    /// Create customized Appearence with specific provider, if no provider is provide, the default value will be used.
    public init(
        colors: ColorProvider? = nil,
        fonts: FontProvider? = nil
    ) {
        self.colors = colors ?? ColorProvider()
        self.fonts = fonts ?? FontProvider()
    }
}
