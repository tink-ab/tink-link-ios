import Foundation
import TinkLink

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        case .invalidArgument:
            return "Invalid argument"
        case .deadlineExceeded:
            return "Deadline Exceeded"
        case .notFound:
            return "Not found"
        case .alreadyExists:
            return "Already exists"
        case .permissionDenied:
            return "Permission denied"
        case .unauthenticated:
            return "Unauthenticated"
        case .resourceExhausted:
            return "Resource exhausted"
        case .failedPrecondition:
            return "Failed precondition"
        case .unavailableForLegalReasons(_):
            return "Unavailable for legal reasons"
        case .aborted:
            return "Aborted"
        case .outOfRange:
            return "Out of range"
        case .unimplemented:
            return "Unimplemented"
        case .internalError:
            return "Internal error"
        case .unavailable:
            return "Unavailable"
        case .dataLoss:
            return "Data loss"
        case .missingInternetConnection:
            return "Missing internet connection"
        }
    }

    public var failureReason: String? {
        switch self {
        case .cancelled:
            return "The user cancelled the request."
        case .unknown(let message),
             .invalidArgument(let message),
             .deadlineExceeded(let message),
             .notFound(let message),
             .alreadyExists(let message),
             .permissionDenied(let message),
             .unauthenticated(let message),
             .resourceExhausted(let message),
             .failedPrecondition(let message),
             .unavailableForLegalReasons(let message),
             .aborted(let message),
             .outOfRange(let message),
             .unimplemented(let message),
             .internalError(let message),
             .unavailable(let message),
             .dataLoss(let message):
            return message
        case .missingInternetConnection:
            return "No internet connection was found."
        }
    }
}
