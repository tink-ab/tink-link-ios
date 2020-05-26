import Foundation
@testable import TinkLink
import XCTest

class BeneficiaryRESTTest: XCTestCase {
    func testBeneficiaryMapping() {
        let restBeneficiary = RESTBeneficiary(
            type: "se",
            accountNumber: "1078646804708704",
            name: "Savings Account tink",
            accountId: "254fa71273394c5890de54fb3d20ac0f"
        )

        let beneficiary = Beneficiary(restBeneficiary: restBeneficiary)

        XCTAssertEqual(beneficiary.accountID.value, restBeneficiary.accountId)
        XCTAssertEqual(beneficiary.accountNumber, restBeneficiary.accountNumber)
        XCTAssertEqual(beneficiary.name, restBeneficiary.name)
        XCTAssertEqual(beneficiary.uri?.scheme, restBeneficiary.type)
        XCTAssertEqual(beneficiary.uri?.host, restBeneficiary.accountNumber)
    }
}
