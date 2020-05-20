import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.accountID = Account.ID(stringLiteral: beneficiary.accountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name

        var urlComponents = URLComponents()
        urlComponents.scheme = beneficiary.type
        urlComponents.host = beneficiary.accountNumber
        urlComponents.queryItems = [URLQueryItem(name: "name", value: beneficiary.name)]
        self.uri = urlComponents.url

    }
}
