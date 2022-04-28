import UIKit

/// A type that can provide custom colors for Tink views.
public struct ColorProvider: ColorProviding {
    /// Colors for indicators and other similar elements background.
    public var accentBackground = UIColor.dynamicColor(
        light: UIColor(red: 236.0 / 255.0, green: 241.0 / 255.0, blue: 243.0 / 255.0, alpha: 1),
        dark: UIColor(red: 3.0 / 255.0, green: 32.0 / 255.0, blue: 39.0 / 255.0, alpha: 1)
    )
    /// Color for primary buttons background and secondary buttons label.
    public var button = UIColor.dynamicColor(
        light: UIColor(red: 66.0 / 255.0, green: 119.0 / 255.0, blue: 131.0 / 255.0, alpha: 1),
        dark: UIColor(red: 14.0 / 255.0, green: 158.0 / 255.0, blue: 194.0 / 255.0, alpha: 1)
    )
    /// Color for the primary buttons label.
    public var buttonLabel = UIColor.dynamicColor(
        light: UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1),
        dark: UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
    )
    /// Color for the main background of the interface.
    public var background = UIColor.dynamicColor(
        light: UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1),
        dark: UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1)
    )
    /// Color for content layered on top of the main background.
    public var secondaryBackground = UIColor.dynamicColor(
        light: UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1),
        dark: UIColor(red: 24.0 / 255.0, green: 24.0 / 255.0, blue: 24.0 / 255.0, alpha: 1)
    )
    /// Color for the main background of grouped interface components.
    @available(*, deprecated, message: "Use background to update elements background")
    public var groupedBackground = UIColor.dynamicColor(
        light: UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1),
        dark: UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1)
    )
    /// Color for content layered on top of the main background of grouped interface components.
    @available(*, deprecated, message: "Use secondaryBackground to update secondary elements background")
    public var secondaryGroupedBackground = UIColor.dynamicColor(
        light: UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1),
        dark: UIColor(red: 24.0 / 255.0, green: 24.0 / 255.0, blue: 24.0 / 255.0, alpha: 1)
    )
    /// Primary text color.
    public var label = UIColor.dynamicColor(
        light: UIColor(red: 38.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0, alpha: 1),
        dark: UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
    )
    /// Secondary text color.
    public var secondaryLabel = UIColor.dynamicColor(
        light: UIColor(red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1),
        dark: UIColor(red: 167.0 / 255, green: 167.0 / 255, blue: 167.0 / 255, alpha: 1)
    )
    /// Color for separators.
    public var separator = UIColor.dynamicColor(
        light: UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1),
        dark: UIColor(red: 57.0 / 255, green: 57.0 / 255, blue: 57.0 / 255, alpha: 1)
    )
    /// Colors for buttons, indicators and other similar elements.
    public var accent = UIColor.dynamicColor(
        light: UIColor(red: 66.0 / 255.0, green: 119.0 / 255.0, blue: 131.0 / 255.0, alpha: 1),
        dark: UIColor(red: 14.0 / 255.0, green: 158.0 / 255.0, blue: 194.0 / 255.0, alpha: 1)
    )
    /// Color representing a warning.
    public var warning = UIColor.dynamicColor(
        light: UIColor(red: 254.0 / 255.0, green: 174.0 / 255.0, blue: 34.0 / 255.0, alpha: 1),
        dark: UIColor(red: 254.0 / 255.0, green: 174.0 / 255.0, blue: 34.0 / 255.0, alpha: 1)
    )
    /// Color representing a critical error or warning.
    public var critical = UIColor.dynamicColor(
        light: UIColor(red: 234.0 / 255.0, green: 84.0 / 255.0, blue: 74.0 / 255.0, alpha: 1),
        dark: UIColor(red: 234.0 / 255.0, green: 84.0 / 255.0, blue: 74.0 / 255.0, alpha: 1)
    )

    /// Color for navigation bar backgrounds.
    public var navigationBarBackground: UIColor?
    /// Color for navigation bar buttons.
    public var navigationBarButton: UIColor?
    /// Color for navigation bar labels.
    public var navigationBarLabel: UIColor?

    /// Initializes a color provider.
    public init() {}

    /// Initializes a color provider with the specified styling.
    ///
    /// - Parameters:
    ///   - background: Color for the main background of the interface.
    ///   - secondaryBackground: Color for content layered on top of the main background.
    ///   - groupedBackground: Color for the main background of grouped interface components.
    ///   - secondaryGroupedBackground: Color for content layered on top of the main background of grouped interface components.
    ///   - label: Primary text color.
    ///   - secondaryLabel: Secondary text color.
    ///   - separator: Color for separators.
    ///   - accent: Colors for buttons, indicators and other similar elements.
    ///   - warning:  Color representing a warning.
    ///   - critical: Color representing a critical error or warning
    @available(*, deprecated, message: "Use init(accent:background:secondaryBackground:label:secondaryLabel:separator:warning:critical:) instead.")
    public init(
        background: UIColor,
        secondaryBackground: UIColor,
        groupedBackground: UIColor,
        secondaryGroupedBackground: UIColor,
        label: UIColor,
        secondaryLabel: UIColor,
        separator: UIColor,
        accent: UIColor,
        warning: UIColor,
        critical: UIColor
    ) {
        self.background = background
        self.secondaryBackground = secondaryBackground
        self.groupedBackground = groupedBackground
        self.secondaryGroupedBackground = secondaryGroupedBackground
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.separator = separator
        self.accent = accent
        self.warning = warning
        self.critical = critical
        self.accentBackground = accent.mixedWith(color: Color.background, factor: 0.95)
        self.button = accent
        self.buttonLabel = background
    }

    @available(*, deprecated, renamed: "init(accent:accentBackground:background:secondaryBackground:label:secondaryLabel:separator:warning:critical:button:buttonLabel:)")
    public init(
        accent: UIColor,
        accentBackground: UIColor?,
        background: UIColor,
        secondaryBackground: UIColor,
        label: UIColor,
        secondaryLabel: UIColor,
        separator: UIColor,
        warning: UIColor,
        critical: UIColor,
        button: UIColor?,
        buttonText: UIColor?
    ) {
        self.accent = accent
        self.accentBackground = accentBackground ?? accent.mixedWith(color: Color.background, factor: 0.95)
        self.background = background
        self.secondaryBackground = secondaryBackground
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.separator = separator
        self.accent = accent
        self.warning = warning
        self.critical = critical
        self.button = button ?? accent
        self.buttonLabel = buttonText ?? background
        self.groupedBackground = background
        self.secondaryGroupedBackground = secondaryBackground
    }

    public init(
        accent: UIColor,
        accentBackground: UIColor?,
        background: UIColor,
        secondaryBackground: UIColor,
        label: UIColor,
        secondaryLabel: UIColor,
        separator: UIColor,
        warning: UIColor,
        critical: UIColor,
        button: UIColor? = nil,
        buttonLabel: UIColor? = nil
    ) {
        self.accent = accent
        self.accentBackground = accentBackground ?? accent.mixedWith(color: Color.background, factor: 0.95)
        self.background = background
        self.secondaryBackground = secondaryBackground
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.separator = separator
        self.accent = accent
        self.warning = warning
        self.critical = critical
        self.button = button ?? accent
        self.buttonLabel = buttonLabel ?? background
    }
}
