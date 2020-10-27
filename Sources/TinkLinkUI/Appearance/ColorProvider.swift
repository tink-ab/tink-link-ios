import UIKit

/// A type that can provide custom colors for Tink views.
public class ColorProvider: ColorProviding {
    /// Colors for indicators and other similar elements background.
    public var accentBackground = UIColor(red: 236.0 / 255.0, green: 241.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    /// Color for primary buttons background and secondary buttons label.
    public var button = UIColor(red: 0.259, green: 0.467, blue: 0.514, alpha: 1.0)
    /// Color for the primary buttons label.
    public var buttonLabel: UIColor = .white
    /// Color for the main background of the interface.
    public var background = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    /// Color for content layered on top of the main background.
    public var secondaryBackground = UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    /// Color for the main background of grouped interface components.
    @available(*, deprecated, message: "Use background to update elements background")
    public var groupedBackground = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    /// Color for content layered on top of the main background of grouped interface components.
    @available(*, deprecated, message: "Use secondaryBackground to update secondary elements background")
    public var secondaryGroupedBackground = UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    /// Primary text color.
    public var label = UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
    /// Secondary text color.
    public var secondaryLabel = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.0)
    /// Color for separators.
    public var separator = UIColor(white: 0.87, alpha: 1.0)
    /// Colors for buttons, indicators and other similar elements.
    public var accent = UIColor(red: 0.259, green: 0.467, blue: 0.514, alpha: 1.0)

    /// Color representing a warning.
    public var warning = UIColor(red: 0.996, green: 0.682, blue: 0.133, alpha: 1.0)
    /// Color representing a critical error or warning.
    public var critical = UIColor(red: 235.0 / 255.0, green: 84.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)

    // Color for navigation bar backgrounds.
    public var navigationBarBackground: UIColor?
    // Color for navigation buttons.
    public var navigationBarButton: UIColor?
    // Color for navigation labels.
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
        buttonText: UIColor? = nil
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
}
