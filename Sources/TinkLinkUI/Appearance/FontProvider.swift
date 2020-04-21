import UIKit

/// A type that can provide custom fonts for Tink views.
public class FontProvider: FontProviding {
    /// Regular font.
    public var regularFont: Font = .systemDefault
    /// Bold font.
    public var boldFont: Font = .systemDefault

    public init() {}

    /// Initializes a appearance provider with the specified styling.
    ///
    /// - Parameters:
    ///   - regularFont: The regular font to use.
    ///   - boldFont: The bold font to use.
    public init(
        regularFont: Font,
        boldFont: Font
    ) {
        self.regularFont = regularFont
        self.boldFont = boldFont
    }

    /// Returns the `Font` to use based on the weight provided.
    /// - Parameter weight: The weight of the font that is asked for.
    public func font(for weight: Font.Weight) -> Font {
        switch weight {
        case .regular: return regularFont
        case .bold: return boldFont
        }
    }
}
