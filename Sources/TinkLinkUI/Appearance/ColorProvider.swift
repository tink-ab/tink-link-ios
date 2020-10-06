import UIKit

/// A type that can provide custom colors for Tink views.
public class ColorProvider: ColorProviding {
    /// Colors for indicators and other similar elements background.
    public var accentBackground: UIColor = UIColor(red: 236.0 / 255.0, green: 241.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    /// Color for buttons background.
    public var button: UIColor = UIColor(red: 0.259, green: 0.467, blue: 0.514, alpha: 1.0)
    /// Color for buttons text.
    public var buttonText: UIColor = .white
    /// Color for the main background of the interface.
    public var background: UIColor = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    /// Color for content layered on top of the main background.
    public var secondaryBackground: UIColor = UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    /// Color for the main background of grouped interface components.
    public var groupedBackground: UIColor = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    /// Color for content layered on top of the main background of grouped interface components.
    public var secondaryGroupedBackground: UIColor = UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    /// Primary text color.
    public var label: UIColor = UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
    /// Secondary text color.
    public var secondaryLabel: UIColor = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.0)
    /// Color for separators.
    public var separator: UIColor = UIColor(white: 0.87, alpha: 1.0)
    /// Colors for buttons, indicators and other similar elements.
    public var accent: UIColor = UIColor(red: 0.259, green: 0.467, blue: 0.514, alpha: 1.0)

    /// Color representing a warning.
    public var warning: UIColor = UIColor(red: 0.996, green: 0.682, blue: 0.133, alpha: 1.0)
    /// Color representing a critical error or warning.
    public var critical: UIColor = UIColor(red: 235.0 / 255.0, green: 84.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)

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
    }
}
