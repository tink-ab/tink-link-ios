import UIKit

/// A type that can provide colors and fonts for Tink views.
public typealias AppearanceProviding = ColorProviding & FontProviding

/// A appearance provider that can provide colors and fonts for Tink views.
public struct AppearanceProvider: AppearanceProviding {

    /// Color for the main background of the interface.
    public let background: UIColor
    /// Color for content layered on top of the main background.
    public let secondaryBackground: UIColor
    /// Color for the main background of grouped interface components.
    public let groupedBackground: UIColor
    /// Color for content layered on top of the main background of grouped interface components.
    public let secondaryGroupedBackground: UIColor
    /// Primary text color.
    public let label: UIColor
    /// Secondary text color.
    public let secondaryLabel: UIColor
    /// Color for separators.
    public let separator: UIColor
    /// Colors for buttons, indicators and other similar elements.
    public let accent: UIColor

    /// Color to represent expenses.
    public let expenses: UIColor
    /// Color to represent incomes.
    public let income: UIColor
    /// Color to represent transfers.
    public let transfers: UIColor
    /// Color representing uncategorized transactions.
    public let uncategorized: UIColor
    /// Color representing a warning.
    public let warning: UIColor
    /// Color representing critical cases.
    public let critical: UIColor

    /// Light font.
    public let lightFont: Font
    /// Regular font.
    public let regularFont: Font
    /// Semibold font.
    public let semiBoldFont: Font
    /// Bold font.
    public let boldFont: Font

    /// Initializes a appearance provider with the specified styling.
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
    ///   - expenses: Color to represent expenses.
    ///   - income: Color to represent incomes.
    ///   - transfers: Color to represent transfers.
    ///   - uncategorized:  Color representing uncategorized transactions.
    ///   - warning:  Color representing a warning.
    ///   - lightFont: The light font to use.
    ///   - regularFont: The regular font to use.
    ///   - semiBoldFont: The semibold font to use.
    ///   - boldFont: The bold font to use.
    ///
    /// - Note: Font parameters defaults to `systemDefault` if not provided.
    public init(
        background: UIColor,
        secondaryBackground: UIColor,
        groupedBackground: UIColor,
        secondaryGroupedBackground: UIColor,
        label: UIColor,
        secondaryLabel: UIColor,
        separator: UIColor,
        accent: UIColor,
        expenses: UIColor,
        income: UIColor,
        transfers: UIColor,
        uncategorized: UIColor,
        warning: UIColor,
        critical: UIColor,
        lightFont: Font = .systemDefault,
        regularFont: Font = .systemDefault,
        semiBoldFont: Font = .systemDefault,
        boldFont: Font = .systemDefault
    ) {
        self.background = background
        self.secondaryBackground = secondaryBackground
        self.groupedBackground = groupedBackground
        self.secondaryGroupedBackground = secondaryGroupedBackground
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.separator = separator
        self.accent = accent
        self.expenses = expenses
        self.income = income
        self.transfers = transfers
        self.uncategorized = uncategorized
        self.warning = warning
        self.critical = critical

        self.lightFont = lightFont
        self.regularFont = regularFont
        self.semiBoldFont = semiBoldFont
        self.boldFont = boldFont
    }

    /// Initializes a appearance provider with the specified styling and system default colors for backgrounds, labels, and separator.
    ///
    /// - Parameters:
    ///   - accent: Colors for buttons, indicators and other similar elements.
    ///   - expenses: Color to represent expenses.
    ///   - income: Color to represent incomes.
    ///   - transfers: Color to represent transfers.
    ///   - uncategorized:  Color representing uncategorized transactions.
    ///   - lightFont: The light font to use.
    ///   - regularFont: The regular font to use.
    ///   - semiBoldFont: The semibold font to use.
    ///   - boldFont: The bold font to use.
    ///
    /// - Note: Font parameters defaults to `systemDefault` if not provided.
    public init(
        accent: UIColor,
        expenses: UIColor,
        income: UIColor,
        transfers: UIColor,
        uncategorized: UIColor,
        lightFont: Font = .systemDefault,
        regularFont: Font = .systemDefault,
        semiBoldFont: Font = .systemDefault,
        boldFont: Font = .systemDefault
    ) {
        if #available(iOS 13.0, *) {
            self.background = .systemBackground
            self.secondaryBackground = .secondarySystemBackground
            self.groupedBackground = .systemGroupedBackground
            self.secondaryGroupedBackground = .secondarySystemGroupedBackground
            self.label = .label
            self.secondaryLabel = .secondaryLabel
            self.separator = .separator
            self.critical = .systemRed
        } else {
            self.background = .white
            self.secondaryBackground = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            self.groupedBackground = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            self.secondaryGroupedBackground = .white
            self.label = .black
            self.secondaryLabel = .darkGray
            self.separator = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
            self.critical = .red
        }
        self.accent = accent
        self.expenses = expenses
        self.income = income
        self.transfers = transfers
        self.uncategorized = uncategorized
        self.warning = uncategorized

        self.lightFont = lightFont
        self.regularFont = regularFont
        self.semiBoldFont = semiBoldFont
        self.boldFont = boldFont
    }

    /// Returns the `Font` to use based on the weight provided.
    /// - Parameter weight: The weight of the font that is asked for.
    public func font(for weight: Font.Weight) -> Font {
        switch weight {
        case .light: return lightFont
        case .regular: return regularFont
        case .semibold: return semiBoldFont
        case .bold: return boldFont
        }
    }
}
