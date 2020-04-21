import UIKit

/// A type that can provide custom fonts for Tink views.
public class FontProvider: FontProviding {
    /// Light font.
    public var lightFont: Font = .systemDefault
    /// Regular font.
    public var regularFont: Font = .systemDefault
    /// Semibold font.
    public var semiBoldFont: Font = .systemDefault
    /// Bold font.
    public var boldFont: Font = .systemDefault

    public init() {}

    /// Initializes a appearance provider with the specified styling.
    ///
    /// - Parameters:
    ///   - lightFont: The light font to use.
    ///   - regularFont: The regular font to use.
    ///   - semiBoldFont: The semibold font to use.
    ///   - boldFont: The bold font to use.
    public init(
        lightFont: Font,
        regularFont: Font,
        semiBoldFont: Font,
        boldFont: Font
    ) {
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
        case .bold: return boldFont
        }
    }
}
