import Foundation
import TinkLink

/// :nodoc:
extension AddCredentialsTask.Error: LocalizedError {
    /// :nodoc:
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return Strings.AddCredentials.Error.permanentFailure
        case .temporaryFailure:
            return Strings.AddCredentials.Error.temporaryFailure
        case .authenticationFailed:
            return Strings.AddCredentials.Error.authenticationFailed
        case .credentialsAlreadyExists:
            return Strings.AddCredentials.Error.credentialsAlreadyExists
        }
    }

    /// :nodoc:
    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            // TODO: Localize this somehow?
            return payload
        case .credentialsAlreadyExists:
            return Strings.AddCredentials.Error.credentialsAlreadyExistsDetail
        }
    }
}
