import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.type = beneficiary.type
        self.accountID = Account.ID(stringLiteral: beneficiary.accountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name

        var urlComponents = URLComponents()
        urlComponents.scheme = beneficiary.type
        urlComponents.host = beneficiary.accountNumber
        if let beneficiaryName = beneficiary.name, !beneficiaryName.isEmpty {
            urlComponents.queryItems = [URLQueryItem(name: "name", value: beneficiaryName)]
        }
        self.uri = urlComponents.url

    }
}
