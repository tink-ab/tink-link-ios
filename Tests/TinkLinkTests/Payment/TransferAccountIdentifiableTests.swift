import XCTest
@testable import TinkLink

class TransferAccountIdentifiableTests: XCTestCase {
    func testAccountConformance() {
        let account = Account.checkingTestAccount
        XCTAssertEqual(account.transferAccountID, "iban://FR1420041010050015664355590?name=testAccount")
    }

    func testAccountURIConformance() {
        let uri = Account.URI(kind: .iban, accountNumber: "FR1420041010050015664355590")
        XCTAssertEqual(uri?.transferAccountID, "iban://FR1420041010050015664355590")
    }

    func testBeneficiaryConformance() {
        let beneficiary = Beneficiary.savingBeneficiary
        XCTAssertEqual(beneficiary.transferAccountID, "se://254fa71273394c5890de54fb3d20ac0f?name=Savings%20Account%20tink")
    }

    func testBeneficiaryAccountConformance() {
        let beneficiary = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")
        XCTAssertEqual(beneficiary.transferAccountID, "iban://FR7630006000011234567890189")
    }

    func testBICAccountURI() {
        let uri = Account.URI(kind: .iban, accountNumber: "AGROFRPR772/FR1420041010050015664355590")
        XCTAssertEqual(uri?.transferAccountID, "iban://AGROFRPR772/FR1420041010050015664355590")
    }

    func testBICBeneficiaryAccount() {
        let beneficiary = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "AGROFRPR772/FR7630006000011234567890189")
        XCTAssertEqual(beneficiary.transferAccountID, "iban://AGROFRPR772/FR7630006000011234567890189")
    }
}
