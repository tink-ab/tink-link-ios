/// An error returned by TinkLink service request when something went wrong during the aggregation.
public enum ServiceError: Error {
    /// Request is cancelled
    case cancelled
    /// Unknown error
    case unknown(String)
    /// Invalid argurment
    case invalidArgument(String)
    /// Deadline exceeded
    case deadlineExceeded(String)
    /// Not found
    case notFound(String)
    /// The resource already exists
    case alreadyExists(String)
    /// The user has no permission
    case permissionDenied(String)
    /// The user has not authenticated
    case unauthenticated(String)
    /// Resource exhausted
    case resourceExhausted(String)
    /// Precondition failed
    case failedPrecondition(String)
    /// The request is aborted
    case aborted(String)
    /// Out of range
    case outOfRange(String)
    /// Not implemented
    case unimplemented(String)
    /// Internal error
    case internalError(String)
    /// The server is not available
    case unavailable(String)
    /// Data loss
    case dataLoss(String)
    /// The internet connection is missing
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
