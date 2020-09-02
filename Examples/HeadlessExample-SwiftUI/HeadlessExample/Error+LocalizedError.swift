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

extension ThirdPartyAppAuthenticationTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(let title, _, _):
            return title
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return "This bank does not support authenticating on another device."
        case .decodingQRCodeImageFailed:
            return "Failed to decode the QR code image."
        }
    }

    public var failureReason: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(_, let message, _):
            return message
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return nil
        case .decodingQRCodeImageFailed:
            return nil
        }
    }
}
