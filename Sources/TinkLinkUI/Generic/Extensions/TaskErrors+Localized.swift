import Foundation
import TinkLink

extension TinkLinkError: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .permanentCredentialsFailure:
            return Strings.Credentials.Error.permanentFailure
        case .temporaryCredentialsFailure:
            return Strings.Credentials.Error.temporaryFailure
        case .credentialsAuthenticationFailed:
            return Strings.Credentials.Error.authenticationFailed
        case .alreadyExists:
            return Strings.Generic.error
        case .credentialsDeleted:
            return Strings.Generic.error
        case .cancelled:
            return Strings.Generic.cancelled
        default:
            return nil
        }
    }

    public var failureReason: String? {
        switch code {
        case .permanentCredentialsFailure, .temporaryCredentialsFailure, .credentialsAuthenticationFailed:
            return message ?? Strings.Generic.error
        case .alreadyExists:
            return Strings.Credentials.Error.credentialsAlreadyExists
        case .cancelled:
            return nil
        default:
            return nil
        }
    }
}

extension ThirdPartyAppAuthenticationTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch code {
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
        switch code {
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
