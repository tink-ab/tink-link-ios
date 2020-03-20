import Foundation
import TinkLink

extension AddCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return "Permanent error"
        case .temporaryFailure:
            return "Temporary error"
        case .authenticationFailed:
            return "Authentication failed"
        case .credentialsAlreadyExists:
            return "Error"
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            return payload
        case .credentialsAlreadyExists:
            return "You already have a connection to this bank or service."
        }
    }
}
