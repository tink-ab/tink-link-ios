import UIKit

/// A type that can provide fonts for Tink views.
public protocol FontProviding {
    /// Returns the `FontType` to use based on the weight provided.
    /// - Parameter weight: The weight of the font that is asked for.
    func font(for weight: Font.Weight) -> Font
}
