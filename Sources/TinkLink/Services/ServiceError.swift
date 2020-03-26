
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
        return nil
        //TODO: ADD mapping to REST errors
    }
}
