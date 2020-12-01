import UIKit

/// A type that can provide colors for Tink views.
public protocol ColorProviding {
    /// Colors for indicators and other similar elements.
    var accent: UIColor { get set }
    /// Colors for indicators and other similar elements background.
    var accentBackground: UIColor { get set }
    /// Color for the main background of the interface.
    var background: UIColor { get set }
    /// Primary text color.
    var label: UIColor { get set }
    /// Secondary text color.
    var secondaryLabel: UIColor { get set }
    /// Color for separators.
    var separator: UIColor { get set }
    /// Color for content layered on top of the main background.
    var secondaryBackground: UIColor { get set }

    /// Color for primary buttons background and secondary buttons label.
    var button: UIColor { get set }
    /// Color for the primary buttons label.
    var buttonLabel: UIColor { get set }

    /// Color for the main background of grouped interface components.
    @available(*, deprecated, message: "Use background to update elements background")
    var groupedBackground: UIColor { get set }
    /// Color for content layered on top of the main background of grouped interface components.
    @available(*, deprecated, message: "Use secondaryBackground to update secondary elements background")
    var secondaryGroupedBackground: UIColor { get set }

    // Semantic colors:
    /// Color representing a warning.
    var warning: UIColor { get set }
    /// Color representing critical cases.
    var critical: UIColor { get set }

    /// Color for navigation bar background.
    var navigationBarBackground: UIColor? { get set }

    /// Color for navigation bar buttons.
    var navigationBarButton: UIColor? { get set }

    /// Color for navigation bar labels.
    var navigationBarLabel: UIColor? { get set }
}

extension ColorProviding {
    var groupedBackground: UIColor { background }
    var secondaryGroupedBackground: UIColor { secondaryBackground }
}
