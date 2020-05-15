import Foundation

public struct TransferDestination: Equatable {

    public enum Kind: Equatable {
        case checking
        case savings
        case investment
        case creditCard
        case loan
        case external
        case unknown
    }

    /// The balance of the account. Will only be populated for accounts that is owned by the user.
    public let balance: Double?

    /// The name of the bank where this destination resides. Will not be populated for payment destinations.
    public let displayBankName: String?

    /// A display formatted alpha-numeric string of the destination account/payment recipient number.
    public let displayAccountNumber: String?

    /// The uri used to describe this destination.
    let uri: Transfer.TransferEntityURI?

    /// The name of the destination if one exists.
    public let name: String?

    /// The account type of the destination. Will be `EXTERNAL` for all destinations not owned by the user.
    public let kind: TransferDestination.Kind

    /// Indicates whether this `TransferDestination` matches multiple destinations.
    /// If true, the uri will be a regular expression, for instance "se-pg://" meaning that the source account can make PG payments.
    public let isMatchingMultipleDestinations: Bool?
}
