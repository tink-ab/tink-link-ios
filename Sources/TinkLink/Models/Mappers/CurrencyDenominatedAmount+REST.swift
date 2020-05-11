import Foundation

extension CurrencyDenominatedAmount {
    init(restCurrencyDenominatedAmount amount: RESTCurrencyDenominatedAmount) {
        self.init(value: ExactNumber(unscaledValue: amount.unscaledValue, scale: Int64(amount.scale)), currencyCode: CurrencyCode(amount.currencyCode))
    }
}
