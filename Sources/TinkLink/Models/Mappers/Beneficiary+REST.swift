import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.accountNumberKind = beneficiary.accountNumberType
        self.ownerAccountID = Account.ID(stringLiteral: beneficiary.ownerAccountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name
    }
}
