import Foundation

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
