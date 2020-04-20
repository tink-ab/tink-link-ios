/// An error returned by TinkLink service request when something went wrong during the aggregation.
public enum ServiceError: Error {
    /// The request was cancelled.
    case cancelled
    /// An unknown error.
    case unknown(String)
    /// The arguements are invalid.
    case invalidArgument(String)
    /// Exceeding the deadline.
    case deadlineExceeded(String)
    /// Endpoint not found.
    case notFound(String)
    /// An aggregated credential exists already.
    case alreadyExists(String)
    /// Permission has denied.
    case permissionDenied(String)
    /// Unauthenticated.
    case unauthenticated(String)
    case resourceExhausted(String)
    case failedPrecondition(String)
    case aborted(String)
    case outOfRange(String)
    case unimplemented(String)
    /// An internal error.
    case internalError(String)
    /// The server is unavailable.
    case unavailable(String)
    /// Data is incomplete.
    case dataLoss(String)
    /// No internet connection.
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
