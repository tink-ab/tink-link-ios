import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.id = Beneficiary.ID(stringLiteral: beneficiary.id)
        self.accountID = Account.ID(stringLiteral: beneficiary.accountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name
        // TODO: Update this
        self.uri = nil
    }
}
