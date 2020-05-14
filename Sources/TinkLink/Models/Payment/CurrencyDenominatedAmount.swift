import Foundation

public struct CurrencyDenominatedAmount: Equatable {
    /// The exact value of the amount
    public let value: ExactNumber
    /// The ISO 4217 currency code of the amount
    public let currencyCode: CurrencyCode

    /// Creates a currency denominated amount.
    ///
    /// - Parameters:
    ///   - value: The exact value of the amount.
    ///   - currencyCode: The exact value of the amount.
    public init(_ value: ExactNumber, currencyCode: CurrencyCode) {
        self.value = value
        self.currencyCode = currencyCode
    }

    /// Creates a currency denominated amount with the amount specified as an integer value.
    ///
    /// - Parameters:
    ///   - value: The exact value of the amount.
    ///   - currencyCode: The exact value of the amount.
    public init(_ value: Int, currencyCode: CurrencyCode) {
        self.value = ExactNumber(value: value)
        self.currencyCode = currencyCode
    }
}
