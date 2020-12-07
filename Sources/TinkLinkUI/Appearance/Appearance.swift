import UIKit
/// A custom appearance provider.
///
/// If you set a custom appearance provider, all TinkLinkUI views will use
/// this provider to retrieve colors and fonts.
///
/// You can change the appearance of Tink Link UI to match the rest of your app.
///
/// To change colors or fonts, update the `Appearance.provider` before initializing the `TinkLinkViewController`.
/// ```swift
/// Appearance.provider.colors.accent = <#UIColor#>
/// ```
public enum Appearance {
    /// The current appearance provider.
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
    /// this provider to retrieve colors.
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
    /// this provider to retrieve fonts.
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
