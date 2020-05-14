import Foundation

extension CurrencyDenominatedAmount {
    init(restCurrencyDenominatedAmount amount: RESTCurrencyDenominatedAmount) {
        self.value = ExactNumber(unscaledValue: amount.unscaledValue, scale: Int64(amount.scale))
        self.currencyCode = CurrencyCode(amount.currencyCode)
    }
}
