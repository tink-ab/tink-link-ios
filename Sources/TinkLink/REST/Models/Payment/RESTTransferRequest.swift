import Foundation

/// A Transfer on Tink represents the tentative action of requesting a payment initiation.
/// By consequence, its success does not represent that money has been successfully transferred from one account to another because the payment initiation relays the responsibility of properly executing the monetary reallocation to the financial institution.
/// The source account must belong to the authenticated user. Source and destination accounts are sent in a special URI format.
struct RESTTransferRequest: Codable {
    /// The amount that will be transferred. Should be positive.
    var amount: Double
    /// The id of the Credentials used to make the transfer. For PIS with AIS it will be the credentials of which the source account belongs to. For PIS without AIS it is not linked to source account.
    var credentialsId: String?
    /// The currency of the amount to be transferred. Should match the SourceUri&#39;s currency.
    var currency: String
    /// The message to the recipient. Optional for bank transfers but required for payments. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
    var destinationMessage: String
    /// The unique identifier of the transfer.
    var id: String?
    /// The transaction description on the source account for the transfer.
    var sourceMessage: String?
    /// The date when the payment or bank transfer should be executed. If no dueDate is given, it will be executed immediately.
    var dueDate: Date?
    /// Transfe's message type, only required for BE and SEPA-EUR schemes. STRUCTURED is for PAYMENT type transfers and FREE_TEXT is for BANK_TRANSFER type transfers.
    var messageType: String?
    /// The destination account or recipient of the transfer, in the form of a uri. With possible scheme: `sepa-eur`, `se-bg`, `se-pg`
    var destinationUri: String
    /// The source account of the transfer, in the form of a uri. With possible scheme: `sepa-eur`, `se-bg`, `se-pg`
    var sourceUri: String

    var redirectUri: String?
}
