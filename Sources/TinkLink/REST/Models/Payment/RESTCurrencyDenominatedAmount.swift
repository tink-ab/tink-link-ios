import Foundation

struct RESTCurrencyDenominatedAmount: Codable {
    /// The unscaled value of the amount
    var unscaledValue: Int64
    /// The scale of the amount.
    var scale: Int
    /// The ISO 4217 currency code of the amount
    var currencyCode: String
}

