import Foundation
import TinkLink

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .missingInternetConnection:
            return "Missing internet connection"
        default:
            return Strings.Generic.ServiceAlert.fallbackTitle
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
