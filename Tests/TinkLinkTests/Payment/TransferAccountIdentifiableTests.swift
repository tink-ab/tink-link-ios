import XCTest
@testable import TinkLink

class TransferAccountIdentifiableTests: XCTestCase {
    func testAccountConformance() {
        let account = Account.checkingTestAccount
        XCTAssertEqual(account.transferAccountID, "iban://FR1420041010050015664355590?name=testAccount")
    }

    func testBeneficiaryConformance() {
        let beneficiary = Beneficiary.savingBeneficiary
        XCTAssertEqual(beneficiary.transferAccountID, "se://254fa71273394c5890de54fb3d20ac0f")
    }
}
