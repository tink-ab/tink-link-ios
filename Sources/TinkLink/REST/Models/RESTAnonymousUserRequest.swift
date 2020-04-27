import Foundation

struct RESTAnonymousUserRequest: Codable {
    let market: String
    let origin: String?
    let locale: String
}

struct RESTAnonymousUserResponse: Codable {
    let access_token: String
}
