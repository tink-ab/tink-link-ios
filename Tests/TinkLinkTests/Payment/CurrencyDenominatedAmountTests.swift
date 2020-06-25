import XCTest
@testable import TinkLink

extension CurrencyDenominatedAmount {
    var doubleValue: Double {
        NSDecimalNumber(decimal: value).doubleValue
    }

    var int64Value: Int64 {
        NSDecimalNumber(decimal: value).int64Value
    }
}

class CurrencyDenominatedAmountTests: XCTestCase {
    func testZero() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 0,
            scale: 0,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 0.0)
        XCTAssertEqual(amount.value, Decimal(string: "0.0"))
    }

    func testOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 1,
            scale: 0,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 1.0)
        XCTAssertEqual(amount.value, Decimal(string: "1.0"))
    }

    func testMinusOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: -1,
            scale: 0,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, -1.0)
        XCTAssertEqual(amount.value, Decimal(string: "-1.0"))
    }

    func testFive() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 5,
            scale: 1,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 0.5)
        XCTAssertEqual(amount.value, Decimal(string: "0.5"))
    }

    func testMinusFive() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: -5,
            scale: 1,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, -0.5)
        XCTAssertEqual(amount.value, Decimal(string: "-0.5"))
    }

    func testOneThousandTwoHundredAndThirtyFour() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 1234,
            scale: 0,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 1234.0)
        XCTAssertEqual(amount.value, Decimal(string: "1234"))
    }

    func testMinusOneThousandTwoHundredAndThirtyFour() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: -1234,
            scale: 0,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, -1234.0)
        XCTAssertEqual(amount.value, Decimal(string: "-1234"))
    }

    func testNineDividedByFour() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 225,
            scale: 2,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 9.0 / 4.0)
        XCTAssertEqual(amount.value, Decimal(string: "2.25"))
    }

    func testMinusNineDividedByFour() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: -225,
            scale: 2,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, -9.0 / 4.0)
        XCTAssertEqual(amount.value, Decimal(string: "-2.25"))
    }

    func testElevenPointSeven() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 117,
            scale: 1,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 11.7)
        XCTAssertEqual(amount.value, Decimal(string: "11.7"))
    }

    func testElevenPointSeventyTwo() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 1172,
            scale: 2,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 11.72)
        XCTAssertEqual(amount.value, Decimal(string: "11.72"))
    }

    func testElevenPointSevenHundredThousandOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 11_700_001,
            scale: 6,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 11.700001)
        XCTAssertEqual(amount.value, Decimal(string: "11.700001"))
    }

    func testElevenPointSevenBillionSomethingOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 11_700_000_000_000_001,
            scale: 15,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 11.700000000000001, accuracy: 0.00000000000001)
        XCTAssertEqual(amount.value, Decimal(string: "11.700000000000001"))
    }

    func testMinusElevenPointSevenBillionSomethingOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: -11_700_000_000_000_001,
            scale: 15,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, -11.700000000000001, accuracy: 0.00000000000001)
        XCTAssertEqual(amount.value, Decimal(string: "-11.700000000000001"))
    }

    func testZeroPointSevenBillionSomethingOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 700_000_000_000_001,
            scale: 15,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, 0.700000000000001, accuracy: 0.00000000000001)
        XCTAssertEqual(amount.value, Decimal(string: "0.700000000000001"))
    }

    func testMinusZeroPointSevenBillionSomethingOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: -700_000_000_000_001,
            scale: 15,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.doubleValue, -0.700000000000001, accuracy: 0.00000000000001)
        XCTAssertEqual(amount.value, Decimal(string: "-0.700000000000001"))
    }

    func testElevenBillionSomethingOne() {
        let restAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 117,
            scale: -14,
            currencyCode: "SEK"
        )
        let amount = CurrencyDenominatedAmount(restCurrencyDenominatedAmount: restAmount)
        XCTAssertEqual(amount.int64Value, 11_700_000_000_000_000)
        XCTAssertEqual(amount.value, Decimal(string: "11700000000000000.0"))
    }
}
