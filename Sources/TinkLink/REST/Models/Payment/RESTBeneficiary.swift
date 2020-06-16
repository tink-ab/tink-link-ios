import Foundation

struct RESTBeneficiary: Decodable {
    var accountNumberType: String
    var accountNumber: String
    var name: String
    var ownerAccountId: String
}
