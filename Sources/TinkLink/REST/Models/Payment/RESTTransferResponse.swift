import Foundation

/// SignableOperation object with the status of the transfer.
struct RESTTransferResponse: Codable {

    enum Status: String, Codable {
        case awaitingCredentials = "AWAITING_CREDENTIALS"
        case awaitingThirdPartyAppAuthentication = "AWAITING_THIRD_PARTY_APP_AUTHENTICATION"
        case created = "CREATED"
        case executing = "EXECUTING"
        case executed = "EXECUTED"
        case sent = "SENT"
        case failed = "FAILED"
        case cancelled = "CANCELLED"
        case unknown = "UNKNOWN"
    }

    enum ModelType: String, Codable {
        case transfer = "TRANSFER"
    }
    /// The timestamp of the creation of the operation.
    var created: Date?
    /// The ID of the Credentials used to make the operation.
    var credentialsId: Date?
    /// The unique identifier of this operation.
    var id: String
    /// The transfer status. The value of this field changes during payment initiation according to `/resources/payments/payment-status-transitions`
    var status: Status
    /// A message with additional information regarding the current status of the transfer.
    var statusMessage: String?
    /// The type of operation.
    var type: ModelType?
    /// The ID of the actual transfer.
    var underlyingId: String?
    /// The timestamp of the last update of the operation.
    var updated: Date?
    /// The ID of the user making the operation.
    var userId: String?
}

