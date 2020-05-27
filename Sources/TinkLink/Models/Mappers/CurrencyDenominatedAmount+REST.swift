import Foundation

extension CurrencyDenominatedAmount {
    init(restCurrencyDenominatedAmount amount: RESTCurrencyDenominatedAmount) {
        self.value = Decimal(
            sign: amount.unscaledValue < 0 ? .minus : .plus,
            exponent: -amount.scale,
            significand: Decimal(amount.unscaledValue)
        )
        self.currencyCode = CurrencyCode(amount.currencyCode)
    }
}
