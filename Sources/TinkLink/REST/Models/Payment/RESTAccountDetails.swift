import Foundation

struct RESTAccountDetails: Codable {

    enum ModelType: String, Codable {
        case mortgage = "MORTGAGE"
        case blanco = "BLANCO"
        case membership = "MEMBERSHIP"
        case vehicle = "VEHICLE"
        case land = "LAND"
        case student = "STUDENT"
        case credit = "CREDIT"
        case other = "OTHER"
    }
    /// Interest of the account. Applicable for loans and savings accounts.
    var interest: Double?

    /// Populated if available. Describes how many months the interest rate is bound.
    var numMonthsBound: Int?

    /// Account subtype.
    var type: ModelType?

    /// A timestamp of the next day of terms change of the account. Applicable for loans.
    var nextDayOfTermsChange: Date?
}

