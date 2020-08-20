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
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            // TODO: Localize this somehow?
            return payload
        case .credentialsAlreadyExists:
            return Strings.Credentials.Error.credentialsAlreadyExists
        }
    }
}

extension RefreshCredentialsTask.Error: LocalizedError {
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

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload), .disabled(let payload):
            // TODO: Localize this somehow?
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
            return Strings.Credentials.Error.doesNotSupportAuthenticatingOnAnotherDevice
        case .decodingQRCodeImageFailed:
            return Strings.Credentials.Error.decodingQRCodeImageFailed
        }
    }

    public var failureReason: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(_, let message, _):
            return message
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            // TODO: Copy
            return nil
        case .decodingQRCodeImageFailed:
            // TODO: Copy
            return nil
        }
    }
}
