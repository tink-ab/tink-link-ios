
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
        if let statusCodeError = error as? HTTPStatusCodeError {
            switch statusCodeError {
            case .badRequest:
                self = .invalidArgument("")
            case .unauthorized:
                self = .unauthenticated("User is not authenticated")
            case .forbidden:
                self = .permissionDenied("")
            case .notFound:
                self = .notFound("")
            case .internalServerError:
                self = .internalError("Internal server error")
            case .serverError(let code):
                self = .internalError("Error code \(code)")
            case .clientError(let code):
                self = .internalError("Error code \(code)")
            }
        }
        return nil
        //TODO: ADD mapping to REST errors
    }
}
