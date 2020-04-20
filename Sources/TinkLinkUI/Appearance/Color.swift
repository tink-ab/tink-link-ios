import UIKit

/// A namespace for custom colors.
public enum Color {

}

// Shorthands for readability
extension Color {
    static var background: UIColor { Appearance.colorProvider.background }
    static var secondaryBackground: UIColor { Appearance.colorProvider.secondaryBackground }
    static var groupedBackground: UIColor { Appearance.colorProvider.groupedBackground }
    static var secondaryGroupedBackground: UIColor { Appearance.colorProvider.secondaryGroupedBackground }
    static var label: UIColor { Appearance.colorProvider.label }
    static var secondaryLabel: UIColor { Appearance.colorProvider.secondaryLabel }
    static var separator: UIColor { Appearance.colorProvider.separator }
    static var accent: UIColor { Appearance.colorProvider.accent }

    static var warning: UIColor { Appearance.colorProvider.warning }
    static var critical : UIColor { Appearance.colorProvider.critical }
}

// Derived colors
extension Color {
    static var highlight: UIColor { accent.withAlphaComponent(0.1) }

    static var accentBackground: UIColor { accent.mixedWith(color: Color.background, factor: 0.95) }

    static var warningBackground: UIColor { warning.mixedWith(color: Color.background, factor: 0.8)}
}
