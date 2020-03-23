import Foundation
import TinkLink

extension AddCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return NSLocalizedString("AddCredentialsTask.Error.PermanentFailure", tableName: "TinkLink", value: "Permanent error", comment: "Title for error shown when a permanent failure occured while adding credentials.")
        case .temporaryFailure:
                return NSLocalizedString("AddCredentialsTask.Error.TemporaryFailure", tableName: "TinkLink", value: "Temporary error", comment: "Title for error shown when a temporary failure occured while adding credentials.")
        case .authenticationFailed:
                return NSLocalizedString("AddCredentialsTask.Error.AuthenticationFailed", tableName: "TinkLink", value: "Authentication failed", comment: "Title for error shown when authentication failed while adding credentials.")
        case .credentialsAlreadyExists:
                return NSLocalizedString("AddCredentialsTask.Error.CredentialsAlreadyExists", tableName: "TinkLink", value: "Error", comment: "Title for error shown when credentials already exists.")
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            // TODO: Localize this somehow?
            return payload
        case .credentialsAlreadyExists:
            return NSLocalizedString("AddCredentialsTask.Error.CredentialsAlreadyExists.FailureReason", tableName: "TinkLink", value: "You already have a connection to this bank or service.", comment: "Message for error shown when credentials already exists.")
        }
    }
}
