import Foundation

/// A Transfer on Tink represents the tentative action of requesting a payment initiation.
/// By consequence, its success does not represent that money has been successfully transferred from one account to another because the payment initiation relays the responsibility of properly executing the monetary reallocation to the financial institution.
/// The source account must belong to the authenticated user. Source and destination accounts are sent in a special URI format.
public struct Transfer {
    /// A unique identifier of a `Transfer`.
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        /// Creates an instance initialized to the given string value.
        /// - Parameter value: The value of the new instance.
        public init(_ value: String) {
            self.value = value
        }

        /// The string value of the ID.
        public let value: String
    }

    /// The amount that will be transferred. Should be positive.
    let amount: Decimal
    /// The unique identifier of the transfer.
    let id: ID?
    /// The id of the Credentials used to make the transfer. For PIS with AIS it will be the credentials of which the source account belongs to. For PIS without AIS it is not linked to source account.
    let credentialsID: Credentials.ID?
    /// The currency of the amount to be transferred. Should match the SourceUri's currency.
    let currency: CurrencyCode
    /// The transaction description on the source account for the transfer.
    let sourceMessage: String?
    /// The message to the recipient. Optional for bank transfers but required for payments. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
    let destinationMessage: String
    /// The date when the payment or bank transfer should be executed. If no `dueDate` is given, it will be executed immediately.
    let dueDate: Date?
    /// The destination account or recipient of the transfer, in the form of a uri. With possible scheme: `sepa-eur`, `se-bg`, `se-pg`
    let destinationUri: String
    /// The source account of the transfer, in the form of a uri. With possible scheme: `sepa-eur`, `se-bg`, `se-pg`
    let sourceUri: String
}
