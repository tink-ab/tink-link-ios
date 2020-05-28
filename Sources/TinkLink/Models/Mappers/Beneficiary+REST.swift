import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.accountNumberType = beneficiary.accountNumberType
        self.ownerAccountID = Account.ID(stringLiteral: beneficiary.ownerAccountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name

        var urlComponents = URLComponents()
        urlComponents.scheme = beneficiary.accountNumberType
        urlComponents.host = beneficiary.accountNumber
        if let beneficiaryName = beneficiary.name, !beneficiaryName.isEmpty {
            urlComponents.queryItems = [URLQueryItem(name: "name", value: beneficiaryName)]
        }
        self.uri = urlComponents.url

    }
}
