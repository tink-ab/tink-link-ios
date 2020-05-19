import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.accountID = Account.ID(stringLiteral: beneficiary.accountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name

        let url = URL(string: "\(beneficiary.type)://\(beneficiary.accountNumber)")
        var urlComponents = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "name", value: beneficiary.name))
        self.uri = urlComponents?.url
    }
}
