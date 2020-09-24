import Foundation
import TinkLink

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingInternetConnection:
            return Strings.Generic.ServiceAlert.missingInternetConnectionTitle
        default:
            return Strings.Generic.ServiceAlert.fallbackTitle
        }
    }

    public var failureReason: String? {
        switch self {
        case .invalidArgument(let message),
             .notFound(let message),
             .alreadyExists(let message),
             .permissionDenied(let message),
             .unauthenticated(let message),
             .failedPrecondition(let message),
             .unavailableForLegalReasons(let message),
             .internalError(let message):
            return message
        case .missingInternetConnection:
            return Strings.Generic.ServiceAlert.missingInternetConnectionMessage
        }
    }
}
