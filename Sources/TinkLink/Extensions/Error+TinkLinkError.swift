import Foundation
import TinkCore

extension Swift.Error {
    var tinkLinkError: Swift.Error {
        switch self {
        case let error as URLError where error.code == .notConnectedToInternet:
            return TinkLinkError(code: .notConnectedToInternet, message: error.localizedDescription)
        case let error as URLError:
            return TinkLinkError(code: .networkFailure, message: error.localizedDescription)
        case let error as ServiceError:
            switch error {
            case .cancelled:
                return TinkLinkError.cancelled(nil)
            case .invalidArgument(let message):
                return TinkLinkError.invalidArguments(message)
            case .notFound(let message):
                return TinkLinkError.notFound(message)
            case .alreadyExists:
                return self
            case .permissionDenied(let message):
                return TinkLinkError.missingRequiredScope(message)
            case .unauthenticated(let message):
                return TinkLinkError.notAuthenticated(message)
            case .failedPrecondition:
                return self
            case .tooManyRequests(let message):
                return TinkLinkError.tooManyRequests(message)
            case .unavailableForLegalReasons(let message):
                return TinkLinkError.unavailableForLegalReasons(message)
            case .internalError(let message):
                return TinkLinkError.internalError(message)
            @unknown default:
                return self
            }
        default:
            return self
        }
    }
}
