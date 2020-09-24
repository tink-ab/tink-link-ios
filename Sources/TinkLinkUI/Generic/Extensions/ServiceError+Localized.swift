import Foundation
import TinkLink

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .invalidArgument:
            return "Invalid argument"
        case .notFound:
            return "Not found"
        case .alreadyExists:
            return "Already exists"
        case .permissionDenied:
            return "Permission denied"
        case .unauthenticated:
            return "Unauthenticated"
        case .failedPrecondition:
            return "Failed precondition"
        case .unavailableForLegalReasons:
            return "Unavailable for legal reasons"
        case .internalError:
            return "Internal error"
        }
    }

    public var failureReason: String? {
        switch self {
        case .cancelled:
            return "The user cancelled the request."
        case .invalidArgument(let message),
             .notFound(let message),
             .alreadyExists(let message),
             .permissionDenied(let message),
             .unauthenticated(let message),
             .failedPrecondition(let message),
             .unavailableForLegalReasons(let message),
             .internalError(let message):
            return message
        }
    }
}
