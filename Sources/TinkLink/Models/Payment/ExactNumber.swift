import Foundation

struct ExactNumber: Equatable, Hashable, Codable {
    let unscaledValue: Int64
    let scale: Int64
}

extension ExactNumber {
    init(value: Decimal) {
        var value = value
        var normalizedSignificand: Int64?

        // Due to inprecision when converting through Double; `11.7` becomes `11.700000000000001` and that turns
        // into a `11700000000000001` significand which doesn’t fit into an Int64 type. The solution is to decrease
        // precision of the significand while changing the exponent.

        repeat {
            if let significand = Int64(exactly: value.significand as NSNumber) {
                normalizedSignificand = significand
            } else {
                var nextValue = Decimal()
                NSDecimalRound(&nextValue, &value, -value.exponent - 1, NSDecimalNumber.RoundingMode.plain)
                value = nextValue
            }
        } while normalizedSignificand == nil && value.exponent < 0

        assert(normalizedSignificand != nil)

        self.scale = Int64(-value.exponent)
        self.unscaledValue = normalizedSignificand ?? 0
    }

    init(value: Int) {
        self.scale = 0
        self.unscaledValue = Int64(value)
    }

    var doubleValue: Double {
        Double(unscaledValue) * pow(10, Double(-scale))
    }
}
