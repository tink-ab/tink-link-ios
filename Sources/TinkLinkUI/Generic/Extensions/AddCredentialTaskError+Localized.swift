import Foundation
import TinkLink

extension AddCredentialTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return "Permanent error"
        case .temporaryFailure:
            return "Temporary error"
        case .authenticationFailed:
            return "Authentication failed"
        case .credentialAlreadyExists:
            return "Error"
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            return payload
        case .credentialAlreadyExists:
            return "You already have a connection to this bank or service."
        }
    }
}
