import UIKit

public enum Appearance {
    /// A custom appearance provider.
    ///
    /// If you set a custom appearance provider, all Tink PFM SDK views will use
    /// this provider to retreive colors and fonts.
    public static var provider: AppearanceProviding! {
        get {
            AppearanceProviderWrapper(colorProvider: colorProvider, fontProvider: fontProvider)
        }
        set {
            if let newProvider = newValue {
                customColorProvider = newProvider
                customFontProvider = newProvider
            } else {
                customColorProvider = nil
                customFontProvider = nil
            }
        }
    }

    static var defaultProvider: AppearanceProviding = DefaultAppearanceProvider()

    /// A custom color provider.
    ///
    /// If you set a custom color provider, all Tink PFM SDK views will use
    /// this provider to retreive colors.
    static var colorProvider: ColorProviding! {
        get {
            customColorProvider ?? defaultProvider
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
            customFontProvider ?? defaultProvider
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

struct AppearanceProviderWrapper: AppearanceProviding {
    let colorProvider: ColorProviding
    let fontProvider: FontProviding

    var background: UIColor { colorProvider.background }

    var secondaryBackground: UIColor { colorProvider.secondaryBackground }

    var groupedBackground: UIColor { colorProvider.groupedBackground }

    var secondaryGroupedBackground: UIColor { colorProvider.secondaryGroupedBackground }

    var label: UIColor { colorProvider.label }

    var secondaryLabel: UIColor { colorProvider.secondaryLabel }

    var separator: UIColor { colorProvider.separator }

    var accent: UIColor { colorProvider.accent }

    var expenses: UIColor { colorProvider.expenses }

    var income: UIColor { colorProvider.income }

    var transfers: UIColor { colorProvider.transfers }

    var uncategorized: UIColor { colorProvider.uncategorized }

    var warning: UIColor { colorProvider.warning }

    var critical: UIColor { colorProvider.critical }

    func font(for weight: Font.Weight) -> Font {
        fontProvider.font(for: weight)
    }
}
