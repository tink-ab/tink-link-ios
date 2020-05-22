import Foundation

struct RESTBeneficiary: Codable {
    var type: String
    var accountNumber: String
    var name: String?
    var accountId: String
}
