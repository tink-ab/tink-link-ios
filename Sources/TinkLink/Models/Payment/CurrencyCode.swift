import Foundation

/// The ISO 4217 currency code of the amount.
public struct CurrencyCode: Hashable, Equatable, ExpressibleByStringLiteral {
    /// The `String` that represent the ISO 4217 currency code.
    public let value: String

    /// Creates a currency code.
    ///
    /// - Parameters:
    ///   - value: The `String` that represent the ISO 4217 currency code.
    public init(_ value: String) {
        self.value = value
    }

    /// Creates a currency code.
    ///
    /// - Parameters:
    ///   - stringLiteral: The `String` that represent the ISO 4217 currency code.
    public init(stringLiteral value: String) {
        self.value = value
    }
}
