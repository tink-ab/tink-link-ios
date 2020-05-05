import Foundation

struct TransferResponse: Codable {

    enum Status: String, Codable {
        case awaitingCredentials = "AWAITING_CREDENTIALS"
        case created = "CREATED"
        case sent = "SENT"
        case failed = "FAILED"
        case cancelled = "CANCELLED"
        case unknown = "UNKNOWN"
    }
    /// The transfer status. The value of this field changes during payment initiation according to `/resources/payments/payment-status-transitions`
    var status: Status
    /// A message with additional information regarding the current status of the transfer.
    var statusMessage: String?
    /// The unique identifier of the transfer.
    var id: String
    /// The destination account or recipient of the transfer, in the form of a uri. With possible scheme: `sepa-eur`, `se-bg`, `se-pg`
    var destinationUri: String
    /// The source account of the transfer, in the form of a uri. Only returned if available from the bank response. With possible scheme: `sepa-eur`, `se-bg`, `se-pg`
    var sourceUri: String

    init(status: Status, statusMessage: String?, id: String, destinationUri: String, sourceUri: String) {
        self.status = status
        self.statusMessage = statusMessage
        self.id = id
        self.destinationUri = destinationUri
        self.sourceUri = sourceUri
    }
}

