import Foundation
import TinkLinkSDK

extension AddCredentialTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return "Permanent error"
        case .temporaryFailure:
            return "Temporary error"
        case .authenticationFailed:
            return "Authentication failed"
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            return payload
        }
    }
}
