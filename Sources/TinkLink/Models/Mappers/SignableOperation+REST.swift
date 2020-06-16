import Foundation

extension SignableOperation {
    init(_ restSignableOperation: RESTSignableOperation) {
        created = restSignableOperation.created
        credentialsID = restSignableOperation.credentialsId.flatMap { Credentials.ID($0) }
        id = restSignableOperation.id.flatMap { SignableOperation.ID($0) }
        status = restSignableOperation.status.flatMap { SignableOperation.Status($0) } ?? .unknown
        statusMessage = restSignableOperation.statusMessage
        kind = .transfer
        transferID = restSignableOperation.underlyingId.flatMap { Transfer.ID($0) }
        updated = restSignableOperation.updated
        userID = restSignableOperation.userId.flatMap { User.ID($0) }
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
            self = .executed
        case .unknown:
            self = .unknown
        }
    }
}
