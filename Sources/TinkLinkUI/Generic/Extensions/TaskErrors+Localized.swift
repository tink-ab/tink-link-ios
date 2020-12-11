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
        case .credentialsDeleted:
            return Strings.Generic.error
        case .credentialsAlreadyExists:
            return Strings.Credentials.Error.credentialsAlreadyExists
        case .cancelled:
            return Strings.Generic.cancelled
        default:
            return Strings.Generic.error
        }
    }

    public var failureReason: String? {
        switch code {
        case .permanentCredentialsFailure, .temporaryCredentialsFailure, .credentialsAuthenticationFailed:
            return message ?? Strings.Generic.error
        case .credentialsAlreadyExists:
            return nil
        case .cancelled:
            return nil
        case .invalidArguments,
             .notFound,
             .missingRequiredScope,
             .notAuthenticated,
             .unavailableForLegalReasons,
             .internalError:
            return message
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
            return downloadTitle ?? Strings.Credentials.Error.downloadRequired
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return nil
        case .decodingQRCodeImageFailed:
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
        default:
            return nil
        }
    }
}
