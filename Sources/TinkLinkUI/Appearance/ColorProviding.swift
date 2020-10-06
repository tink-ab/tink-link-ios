import UIKit

/// A type that can provide colors for Tink views.
public protocol ColorProviding {
    /// Colors for indicators and other similar elements.
    var accent: UIColor { get }
    /// Colors for indicators and other similar elements background.
    var accentBackground: UIColor { get }
    /// Color for the main background of the interface.
    var background: UIColor { get }
    /// Primary text color.
    var label: UIColor { get }
    /// Secondary text color.
    var secondaryLabel: UIColor { get }
    /// Color for separators.
    var separator: UIColor { get }
    /// Color for content layered on top of the main background.
    var secondaryBackground: UIColor { get }

    /// Color for buttons background.
    var button: UIColor { get }
    /// Color for buttons text.
    var buttonText: UIColor { get }

    /// Color for the main background of grouped interface components.
    @available(*, deprecated, message: "Use accentBackground to update elements background")
    var groupedBackground: UIColor { get }
    /// Color for content layered on top of the main background of grouped interface components.
    @available(*, deprecated, message: "Use accentBackground to update elements background")
    var secondaryGroupedBackground: UIColor { get }

    // Semantic colors:
    /// Color representing a warning.
    var warning: UIColor { get }
    /// Color representing critical cases.
    var critical: UIColor { get }
}
