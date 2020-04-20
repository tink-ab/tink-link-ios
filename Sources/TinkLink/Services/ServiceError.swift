/// An error returned by TinkLink service request when something went wrong during the aggregation.
public enum ServiceError: Error {
    case cancelled
    case unknown(String)
    case invalidArgument(String)
    case deadlineExceeded(String)
    case notFound(String)
    case alreadyExists(String)
    case permissionDenied(String)
    case unauthenticated(String)
    case resourceExhausted(String)
    case failedPrecondition(String)
    case aborted(String)
    case outOfRange(String)
    case unimplemented(String)
    case internalError(String)
    case unavailable(String)
    case dataLoss(String)
    case missingInternetConnection

    init?(_ error: Swift.Error) {
        if let restError = error as? RESTError, let statusCodeError = restError.statusCodeError {
            switch statusCodeError {
            case .badRequest:
                self = .invalidArgument(restError.errorMessage ?? "")
            case .unauthorized:
                self = .unauthenticated(restError.errorMessage ?? "User is not authenticated")
            case .forbidden:
                self = .permissionDenied(restError.errorMessage ?? "")
            case .notFound:
                self = .notFound(restError.errorMessage ?? "")
            case .internalServerError:
                self = .internalError(restError.errorMessage ?? "Internal server error")
            case .serverError(let code):
                self = .internalError(restError.errorMessage ?? "Error code \(code)")
            case .clientError(let code):
                self = .internalError(restError.errorMessage ?? "Error code \(code)")
            }
        } else {
            return nil
        }
    }
}
