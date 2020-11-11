import Foundation
import TinkLink

extension AddCredentialsTask.Error: LocalizedError {
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
        case .cancelled:
            return Strings.Generic.cancelled
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            return payload ?? Strings.Generic.error
        case .credentialsAlreadyExists:
            return Strings.Credentials.Error.credentialsAlreadyExists
        case .cancelled:
            return nil
        }
    }
}

extension RefreshCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .permanentFailure:
            return Strings.Credentials.Error.permanentFailure
        case .temporaryFailure:
            return Strings.Credentials.Error.temporaryFailure
        case .authenticationFailed:
            return Strings.Credentials.Error.authenticationFailed
        case .deleted:
            return Strings.Generic.error
        case .cancelled:
            return Strings.Generic.cancelled
        default:
            return nil
        }
    }

    public var failureReason: String? {
        switch code {
        case .cancelled:
            return nil
        default:
            return message ?? Strings.Generic.error
        }
    }
}

extension ThirdPartyAppAuthenticationTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired:
            return downloadTitle
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return nil
        case .decodingQRCodeImageFailed:
            return nil
        case .cancelled:
            return nil
        default:
            return nil
        }
    }

    public var failureReason: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired:
            return downloadMessage
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return nil
        case .decodingQRCodeImageFailed:
            return nil
        case .cancelled:
            return nil
        default:
            return nil
        }
    }
}
