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

    static var expenses: UIColor { Appearance.colorProvider.expenses }
    static var income: UIColor { Appearance.colorProvider.income }
    static var transfers: UIColor { Appearance.colorProvider.transfers }
    static var uncategorized: UIColor { Appearance.colorProvider.uncategorized }
    static var warning: UIColor { Appearance.colorProvider.warning }
}

// Derived colors
extension Color {
    static var highlight: UIColor { accent.withAlphaComponent(0.1) }

    static var accentBackground: UIColor { accent.mixedWith(color: Color.background, factor: 0.85) }

    static var expensesIconBackground: UIColor { expenses.mixedWith(color: Color.background, factor: 0.85) }
    static var incomeIconBackground: UIColor { income.mixedWith(color: Color.background, factor: 0.8) }
    static var uncategorizedIconBackground: UIColor { uncategorized.mixedWith(color: Color.background, factor: 0.9) }
    static var transfersIconBackground: UIColor { transfers.mixedWith(color: Color.background, factor: 0.9) }

    static var expensesChartBackground: UIColor { expenses.mixedWith(color: Color.background, factor: 0.85) }
    static var incomeChartBackground: UIColor { income.mixedWith(color: Color.background, factor: 0.8) }
}
