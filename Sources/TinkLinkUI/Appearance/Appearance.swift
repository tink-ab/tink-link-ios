import UIKit

public enum Appearance {
    /// A custom appearance provider.
    ///
    /// If you set a custom appearance provider, all Tink PFM SDK views will use
    /// this provider to retreive colors and fonts.
    public static var provider: AppearanceProviding = AppearanceProvider() {
        didSet {
            customColorProvider = provider.colors
            customFontProvider = provider.fonts
        }
    }

    static var defaultProvider: AppearanceProviding = AppearanceProvider()

    /// A custom color provider.
    ///
    /// If you set a custom color provider, all Tink PFM SDK views will use
    /// this provider to retreive colors.
    static var colorProvider: ColorProviding! {
        get {
            customColorProvider ?? defaultProvider.colors
        }
        set {
            if let newProvider = newValue {
                customColorProvider = newProvider
            } else {
                customColorProvider = nil
            }
        }
    }

    private static var customColorProvider: ColorProviding?

    /// A custom font provider.
    ///
    /// If you set a custom font provider, all Tink PFM SDK views will use
    /// this provider to retreive fonts.
    static var fontProvider: FontProviding! {
        get {
            customFontProvider ?? defaultProvider.fonts
        }
        set {
            if let newProvider = newValue {
                customFontProvider = newProvider
            } else {
                customFontProvider = nil
            }
        }
    }

    private static var customFontProvider: FontProviding?
}
