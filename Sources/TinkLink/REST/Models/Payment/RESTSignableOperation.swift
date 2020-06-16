import Foundation

/// SignableOperation object with the status of the transfer.
struct RESTSignableOperation: Decodable {
    enum Status: String, DefaultableDecodable {
        case awaitingCredentials = "AWAITING_CREDENTIALS"
        case awaitingThirdPartyAppAuthentication = "AWAITING_THIRD_PARTY_APP_AUTHENTICATION"
        case created = "CREATED"
        case executing = "EXECUTING"
        case executed = "EXECUTED"
        case sent = "SENT"
        case failed = "FAILED"
        case cancelled = "CANCELLED"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTSignableOperation.Status = .unknown
    }

    enum ModelType: String, DefaultableDecodable {
        case transfer = "TRANSFER"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTSignableOperation.ModelType = .unknown
    }

    /// The timestamp for when the operation was created.
    var created: Date?
    /// The ID of the Credentials used to make the operation.
    var credentialsId: String?
    /// The unique identifier of this operation.
    var id: String?
    /// The transfer status. The value of this field changes during payment initiation according to `/resources/payments/payment-status-transitions`
    var status: Status?
    /// A message with additional information regarding the current status of the transfer.
    var statusMessage: String?
    /// The type of operation.
    var type: ModelType?
    /// The ID of the actual transfer.
    var underlyingId: String?
    /// The timestamp for when the operation was updated.
    var updated: Date?
    /// The ID of the user making the operation.
    var userId: String?
}
