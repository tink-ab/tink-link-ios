import Foundation

struct RESTUser: Decodable {
    /// The date when the user was created.
    var created: Date?
    /// The user-specific feature flags assigned to the user.
    var flags: [String]
    /// The internal identifier of the user.
    var id: String
    /// Detected national identification number of the end-user.
    var nationalId: String?
    /// The configurable profile of the user.
    var profile: RESTUserProfile
    /// The username (usually email) of the user.
    var username: String?
}

struct RESTUserProfile: Decodable {
    enum PeriodMode: String, Codable {
        case monthly = "MONTHLY"
        case monthlyAdjusted = "MONTHLY_ADJUSTED"
    }

    var currency: String
    var locale: String
    var market: String
    var periodAdjustedDay: Int
    var periodMode: PeriodMode
    var timeZone: String
}
