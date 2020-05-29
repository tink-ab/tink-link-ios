import Foundation

struct RESTBeneficiary: Codable {
    var accountNumberType: String
    var accountNumber: String
    var name: String?
    var ownerAccountId: String
}
