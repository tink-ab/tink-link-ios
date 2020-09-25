import Foundation
import TinkLink

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return Strings.Generic.cancelled
        default:
            return Strings.Generic.ServiceAlert.fallbackTitle
        }
    }

    public var failureReason: String? {
        switch self {
        case .cancelled:
            return nil
        case .invalidArgument(let message),
             .notFound(let message),
             .alreadyExists(let message),
             .permissionDenied(let message),
             .unauthenticated(let message),
             .failedPrecondition(let message),
             .unavailableForLegalReasons(let message),
             .internalError(let message):
            return message.isEmpty ? nil : message
        }
    }
}
