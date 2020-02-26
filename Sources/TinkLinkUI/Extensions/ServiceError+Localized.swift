import Foundation
import TinkLink

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .unknown(_):
            return "Unknown error"
        case .invalidArgument(_):
            return "Invalid argument"
        case .deadlineExceeded(_):
            return "Deadline Exceeded"
        case .notFound(_):
            return "Not found"
        case .alreadyExists(_):
            return "Already exists"
        case .permissionDenied(_):
            return "Permission denied"
        case .unauthenticated(_):
            return "Unauthenticated"
        case .resourceExhausted(_):
            return "Resource exhausted"
        case .failedPrecondition(_):
            return "Failed precondition"
        case .aborted(_):
            return "Aborted"
        case .outOfRange(_):
            return "Out of range"
        case .unimplemented(_):
            return "Unimplemented"
        case .internalError(_):
            return "Internal error"
        case .unavailable(_):
            return "Unavailable"
        case .dataLoss(_):
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
