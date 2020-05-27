import Foundation
@testable import TinkLink
import XCTest

extension Beneficiary {
    static let savingBeneficiary = Beneficiary(
        type: "se",
        name: "Savings Account tink",
        accountID: "1078646804708704",
        accountNumber: "254fa71273394c5890de54fb3d20ac0f",
        uri: URL(string: "se://254fa71273394c5890de54fb3d20ac0f")
    )
}
