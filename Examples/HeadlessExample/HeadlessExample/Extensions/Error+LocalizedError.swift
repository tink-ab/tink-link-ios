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
        case .cancelled:
            return "Cancelled"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationFailed(let payload),
             .credentialsAlreadyExists(let payload),
             .permanentFailure(let payload),
             .temporaryFailure(let payload):
            return payload
        case .cancelled:
            return nil
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
        case .cancelled:
            return "Cancelled"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationFailed(let payload),
             .permanentFailure(let payload),
             .temporaryFailure(let payload),
             .disabled(let payload):
            return payload
        case .cancelled:
            return nil
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

extension AddBeneficiaryTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication Failed"
        case .disabledCredentials:
            return "Disabled Credentials"
        case .credentialsSessionExpired:
            return "Credentials Session Expired"
        case .notFound:
            return "Not Found"
        case .invalidBeneficiary:
            return "Invalid beneficiary"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationFailed(let payload),
             .disabledCredentials(let payload),
             .credentialsSessionExpired(let payload),
             .notFound(let payload),
             .invalidBeneficiary(let payload):
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
        case .cancelled:
            return "Cancelled"
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
        case .cancelled:
            return nil
        }
    }
}

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Request is cancelled"
        case .invalidArgument:
            return "Invalid argurment"
        case .notFound:
            return "Not found"
        case .alreadyExists:
            return "The resource already exists"
        case .permissionDenied:
            return "The user has no permission"
        case .unauthenticated:
            return "The user has not authenticated"
        case .failedPrecondition:
            return "Precondition failed"
        case .unavailableForLegalReasons:
            return "The request cannot be fulfilled because of legal/contractual reasons."
        case .internalError:
            return "Internal error"
        }
    }

    public var failureReason: String? {
        switch self {
        case .cancelled:
            return nil
        case .invalidArgument(let payload),
             .notFound(let payload),
             .alreadyExists(let payload),
             .permissionDenied(let payload),
             .unauthenticated(let payload),
             .failedPrecondition(let payload),
             .unavailableForLegalReasons(let payload),
             .internalError(let payload):
            return payload
        }
    }
}
