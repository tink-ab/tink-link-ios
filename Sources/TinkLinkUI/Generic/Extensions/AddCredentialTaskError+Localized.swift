import Foundation
import TinkLink

/// :nodoc:
extension AddCredentialsTask.Error: LocalizedError {
    /// :nodoc:
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return Strings.Credentials.Error.permanentFailure
        case .temporaryFailure:
            return Strings.Credentials.Error.temporaryFailure
        case .authenticationFailed:
            return Strings.Credentials.Error.authenticationFailed
        case .credentialsAlreadyExists:
            return Strings.Generic.error
        }
    }

    /// :nodoc:
    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            // TODO: Localize this somehow?
            return payload
        case .credentialsAlreadyExists:
            return Strings.Credentials.Error.credentialsAlreadyExistsDetail
        }
    }
}

extension RefreshCredentialsTask.Error: LocalizedError {
    /// :nodoc:
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return Strings.Credentials.Error.permanentFailure
        case .temporaryFailure:
            return Strings.Credentials.Error.temporaryFailure
        case .authenticationFailed:
            return Strings.Credentials.Error.authenticationFailed
        case .disabled:
            return Strings.Generic.error
        }
    }

    /// :nodoc:
    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload), .disabled(let payload):
            // TODO: Localize this somehow?
            return payload
        }
    }
}
