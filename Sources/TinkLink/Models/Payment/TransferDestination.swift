import Foundation

struct TransferDestination: Equatable {
    enum Kind: Equatable {
        case checking
        case savings
        case investment
        case creditCard
        case loan
        case external
        case unknown
    }

    /// The balance of the account. Will only be populated for accounts that is owned by the user.
    let balance: Double?

    /// The name of the bank where this destination resides. Will not be populated for payment destinations.
    let displayBankName: String?

    /// A display formatted alpha-numeric string of the destination account/payment recipient number.
    let displayAccountNumber: String?

    /// The uri used to describe this destination.
    let uri: URL?

    /// The name of the destination if one exists.
    let name: String?

    /// The account type of the destination. Will be `EXTERNAL` for all destinations not owned by the user.
    let kind: TransferDestination.Kind

    /// Indicates whether this `TransferDestination` matches multiple destinations.
    /// If true, the uri will be a regular expression, for instance "se-pg://" meaning that the source account can make PG payments.
    let isMatchingMultipleDestinations: Bool?
}
