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

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Request is cancelled"
        case .unknown:
            return "Unknown error"
        case .invalidArgument:
            return "Invalid argurment"
        case .deadlineExceeded:
            return "Deadline exceeded"
        case .notFound:
            return "Not found"
        case .alreadyExists:
            return "The resource already exists"
        case .permissionDenied:
            return "The user has no permission"
        case .unauthenticated:
            return "The user has not authenticated"
        case .resourceExhausted:
            return "Resource exhausted"
        case .failedPrecondition:
            return "Precondition failed"
        case .aborted:
            return "The request is aborted"
        case .outOfRange:
            return "Out of range"
        case .unimplemented:
            return "Not implemented"
        case .internalError:
            return "Internal error"
        case .unavailable:
            return "The server is not available"
        case .dataLoss:
            return "Data loss"
        case .missingInternetConnection:
            return "The internet connection is missing"
        }
    }

    public var failureReason: String? {
        switch self {
        case .cancelled:
            return nil
        case .unknown(let payload),
             .invalidArgument(let payload),
             .deadlineExceeded(let payload),
             .notFound(let payload),
             .alreadyExists(let payload),
             .permissionDenied(let payload),
             .unauthenticated(let payload),
             .resourceExhausted(let payload),
             .failedPrecondition(let payload),
             .aborted(let payload),
             .outOfRange(let payload),
             .unimplemented(let payload),
             .internalError(let payload),
             .unavailable(let payload),
             .dataLoss(let payload):
            return payload
        case .missingInternetConnection:
            return nil
        }
    }
}
