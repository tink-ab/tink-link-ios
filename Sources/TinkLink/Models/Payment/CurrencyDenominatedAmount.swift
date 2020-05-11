import Foundation

public struct CurrencyDenominatedAmount: Equatable {
    /// The exact value of the amount
    public let value: ExactNumber
    /// The ISO 4217 currency code of the amount
    public let currencyCode: CurrencyCode
}

