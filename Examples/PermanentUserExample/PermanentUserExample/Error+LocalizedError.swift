import Foundation
import TinkLink

extension AddCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication Failed"
        case .credentialsAlreadyExists:
            return "Credentials Already Exists"
        case .permanentFailure:
            return "Permanent Failure"
        case .temporaryFailure:
            return "Temporary Failure"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationFailed(let payload),
             .credentialsAlreadyExists(let payload),
             .permanentFailure(let payload),
             .temporaryFailure(let payload):
            return payload
        }
    }
}

extension RefreshCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication Failed"
        case .permanentFailure:
            return "Permanent Failure"
        case .temporaryFailure:
            return "Temporary Failure"
        case .disabled:
            return "Disabled"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationFailed(let payload),
             .permanentFailure(let payload),
             .temporaryFailure(let payload),
             .disabled(let payload):
            return payload
        }
    }
}

extension InitiateTransferTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication Failed"
        case .disabledCredentials:
            return "Disabled Credentials"
        case .credentialsSessionExpired:
            return "Credentials Session Expired"
        case .cancelled:
            return "Cancelled"
        case .failed:
            return "Failed"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationFailed(let payload),
             .disabledCredentials(let payload),
             .credentialsSessionExpired(let payload),
             .cancelled(let payload),
             .failed(let payload):
            return payload
        }
    }
}
