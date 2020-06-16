import Foundation

struct RESTTransferDestination: Decodable {
    enum ModelType: String, DefaultableDecodable {
        case checking = "CHECKING"
        case savings = "SAVINGS"
        case investment = "INVESTMENT"
        case creditCard = "CREDIT_CARD"
        case loan = "LOAN"
        case external = "EXTERNAL"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTTransferDestination.ModelType = .unknown
    }

    /// The balance of the account. Will only be populated for accounts that is owned by the user.
    var balance: Double?

    /// The name of the bank where this destination resides. Will not be populated for payment destinations.
    var displayBankName: String?

    /// A display formatted alpha-numeric string of the destination account/payment recipient number.
    var displayAccountNumber: String?

    /// The uri used to describe this destination.
    var uri: String?

    /// The name of the destination if one exists.
    var name: String?

    /// The account type of the destination. Will be `EXTERNAL` for all destinations not owned by the user.
    var type: ModelType?

    /// Indicates whether this `TransferDestination` matches multiple destinations.
    /// If true, the uri will be a regular expression, for instance "se-pg://" meaning that the source account can make PG payments.
    var matchesMultiple: Bool?
}
