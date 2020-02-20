enum ServiceError: Error {
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

    init?(_ error: Swift.Error) {
        guard let status = error as? GRPC.GRPCStatus else { return nil }
        switch status.code {
        case .cancelled:
            self = .cancelled
        case .unknown:
            self = .unknown(status.message ?? "")
        case .invalidArgument:
            self = .invalidArgument(status.message ?? "")
        case .deadlineExceeded:
            self = .deadlineExceeded(status.message ?? "")
        case .notFound:
            self = .notFound(status.message ?? "")
        case .alreadyExists:
            self = .alreadyExists(status.message ?? "")
        case .permissionDenied:
            self = .permissionDenied(status.message ?? "")
        case .unauthenticated:
            self = .unauthenticated(status.message ?? "")
        case .resourceExhausted:
            self = .resourceExhausted(status.message ?? "")
        case .failedPrecondition:
            self = .failedPrecondition(status.message ?? "")
        case .aborted:
            self = .aborted(status.message ?? "")
        case .outOfRange:
            self = .outOfRange(status.message ?? "")
        case .unimplemented:
            self = .unimplemented(status.message ?? "")
        case .internalError:
            self = .internalError(status.message ?? "")
        case .unavailable:
            self = .unavailable(status.message ?? "")
        case .dataLoss:
            self = .dataLoss(status.message ?? "")
        default:
            return nil
        }
    }
}
