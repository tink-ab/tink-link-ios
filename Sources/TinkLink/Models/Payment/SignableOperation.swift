import Foundation

/// SignableOperation object with the status of the transfer.
struct SignableOperation {
    /// A unique identifier of a `SignableOperation`.
    struct ID: Hashable, ExpressibleByStringLiteral {
        init(stringLiteral value: String) {
            self.value = value
        }

        init(_ value: String) {
            self.value = value
        }

        let value: String
    }

    enum Status {
        case awaitingCredentials
        case awaitingThirdPartyAppAuthentication
        case created
        case executing
        case executed
        case failed
        case cancelled
        case unknown
    }

    enum Kind {
        case transfer
    }

    /// The timestamp of the creation of the operation.
    let created: Date?
    /// The ID of the Credentials used to make the operation.
    let credentialsID: Credentials.ID?
    /// The unique identifier of this operation.
    let id: ID?
    /// The transfer status. The value of this field changes during payment initiation according to `/resources/payments/payment-status-transitions`
    let status: Status
    /// A message with additional information regarding the current status of the transfer.
    let statusMessage: String?
    /// The type of operation.
    let kind: Kind
    /// The ID of the actual transfer.
    let transferID: Transfer.ID?
    /// The timestamp of the last update of the operation.
    let updated: Date?
    /// The ID of the user making the operation.
    let userID: User.ID?
}
