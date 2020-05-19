import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        // TODO: Change this
        self.id = Beneficiary.ID(stringLiteral: beneficiary.name)
        self.accountID = Account.ID(stringLiteral: beneficiary.accountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name
        // TODO: Change this
        self.uri = nil
    }
}
