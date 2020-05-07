import Foundation

extension SignableOperation {
    init(_ restSignableOperation: RESTSignableOperation) {
        created = restSignableOperation.created ?? Date()
        credentialsID = restSignableOperation.credentialsId.flatMap({ Credentials.ID($0) })
        id = restSignableOperation.id.flatMap({ SignableOperation.ID($0) })
        status = restSignableOperation.status.flatMap({ SignableOperation.Status($0) }) ?? .unknown
        statusMessage = restSignableOperation.statusMessage ?? String()
        type = .transfer
        transferID = restSignableOperation.underlyingId.flatMap({ Transfer.ID($0) })
        updated = restSignableOperation.updated ?? Date()
        userID = restSignableOperation.userId
    }
}

extension SignableOperation.Status {
    init(_ status: RESTSignableOperation.Status) {
        switch status {
        case .awaitingCredentials:
            self = .awaitingCredentials
        case .awaitingThirdPartyAppAuthentication:
            self = .awaitingThirdPartyAppAuthentication
        case .cancelled:
            self = .cancelled
        case .created:
            self = .created
        case .executed:
            self = .executed
        case .executing:
            self = .executing
        case .failed:
            self = .failed
        case .sent:
            self = .sent
        case .unknown:
            self = .unknown
        }
    }
}
