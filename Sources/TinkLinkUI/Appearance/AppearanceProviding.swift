import UIKit

/// A type that can provide colors and fonts for Tink views.
public protocol AppearanceProviding {
    var colors: ColorProviding { get }
    var fonts: FontProviding { get }
}

/// A appearance provider that can provide colors and fonts for Tink views.
public struct AppearanceProvider: AppearanceProviding {
    public let colors: ColorProviding
    public let fonts: FontProviding

    public init(
        colors: ColorProvider? = nil,
        fonts: FontProvider? = nil
    ) {
        self.colors = colors ?? ColorProvider()
        self.fonts = fonts ?? FontProvider()
    }
}
