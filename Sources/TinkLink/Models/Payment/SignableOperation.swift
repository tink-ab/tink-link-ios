import Foundation

/// SignableOperation object with the status of the transfer.
public struct SignableOperation {
    // TODO: Maybe update the naming a bit

    /// A unique identifier of a `SignableOperation`.
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

        public let value: String
    }

    enum Status {
        case awaitingCredentials
        case awaitingThirdPartyAppAuthentication
        case created
        case executing
        case executed
        case sent
        case failed
        case cancelled
        case unknown
    }

    enum ModelType {
        case transfer
    }

    /// The timestamp of the creation of the operation.
    let created: Date
    /// The ID of the Credentials used to make the operation.
    let credentialsId: Credentials.ID
    /// The unique identifier of this operation.
    let id: ID
    /// The transfer status. The value of this field changes during payment initiation according to `/resources/payments/payment-status-transitions`
    let status: Status
    /// A message with additional information regarding the current status of the transfer.
    let statusMessage: String
    /// The type of operation.
    let type: ModelType
    /// The ID of the actual transfer.
    let underlyingId: Transfer.ID
    /// The timestamp of the last update of the operation.
    let updated: Date

    // TODO: Not 100% sure what is this here for now
    /// The ID of the user making the operation.
    let userId: String
}
