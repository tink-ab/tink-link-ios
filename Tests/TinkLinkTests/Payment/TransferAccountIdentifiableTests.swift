import XCTest
@testable import TinkLink

class TransferAccountIdentifiableTests: XCTestCase {
    func testAccount() {
        let account = Account.checkingTestAccount
        XCTAssertEqual(account.transferAccountID, "iban://FR1420041010050015664355590?name=testAccount")
    }
}
