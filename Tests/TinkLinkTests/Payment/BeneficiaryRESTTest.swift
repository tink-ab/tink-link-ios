import Foundation
@testable import TinkLink
import XCTest

class BeneficiaryRESTTest: XCTestCase {
    func testBeneficiaryMapping() {
        let restBeneficiary = RESTBeneficiary(
            accountNumberType: "se",
            accountNumber: "1078646804708704",
            name: "Savings Account tink",
            ownerAccountId: "254fa71273394c5890de54fb3d20ac0f"
        )

        let beneficiary = Beneficiary(restBeneficiary: restBeneficiary)

        XCTAssertEqual(beneficiary.ownerAccountID.value, restBeneficiary.ownerAccountId)
        XCTAssertEqual(beneficiary.accountNumber, restBeneficiary.accountNumber)
        XCTAssertEqual(beneficiary.name, restBeneficiary.name)
    }

    func testBeneficiaryURIMapping() {
        let beneficiary = Beneficiary.savingBeneficiary
        let uri = Beneficiary.URI(beneficiary: beneficiary)
        XCTAssertEqual(uri?.uri.scheme, beneficiary.accountNumberType)
        XCTAssertEqual(uri?.uri.host, beneficiary.accountNumber)
    }
}
