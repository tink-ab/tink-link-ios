import Foundation

struct RESTAccountListResponse: Decodable {
    /// A list of accounts
    var accounts: [RESTAccount]
}
