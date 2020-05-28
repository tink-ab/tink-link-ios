import Foundation

/// A amount that's denominated with a `CurrencyCode`.
public struct CurrencyDenominatedAmount: Equatable {
    /// The exact value of the amount
    public let value: Decimal
    /// The ISO 4217 currency code of the amount
    public let currencyCode: CurrencyCode

    /// Creates a currency denominated amount.
    ///
    /// - Parameters:
    ///   - value: The exact value of the amount.
    ///   - currencyCode: The ISO 4217 currency code of the amount.
    public init(_ value: Decimal, currencyCode: CurrencyCode) {
        self.value = value
        self.currencyCode = currencyCode
    }

    /// Creates a currency denominated amount with the amount specified as an integer value.
    ///
    /// - Parameters:
    ///   - value: The exact value of the amount.
    ///   - currencyCode: The ISO 4217 currency code of the amount.
    public init(_ value: Int, currencyCode: CurrencyCode) {
        self.value = Decimal(value)
        self.currencyCode = currencyCode
    }
}
