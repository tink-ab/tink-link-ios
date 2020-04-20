import UIKit

/// A type that can provide colors for Tink views.
public protocol ColorProviding {

    /// Color for the main background of the interface.
    var background: UIColor { get }
    /// Color for content layered on top of the main background.
    var secondaryBackground: UIColor { get }
    /// Color for the main background of grouped interface components.
    var groupedBackground: UIColor { get }
    /// Color for content layered on top of the main background of grouped interface components.
    var secondaryGroupedBackground: UIColor { get }
    /// Primary text color.
    var label: UIColor { get }
    /// Secondary text color.
    var secondaryLabel: UIColor { get }
    /// Color for separators.
    var separator: UIColor { get }
    /// Colors for buttons, indicators and other similar elements.
    var accent: UIColor { get }

    // Semantic colors:
    /// Color representing a warning.
    var warning: UIColor { get }
    /// Color representing critical cases.
    var critical: UIColor { get }
}
