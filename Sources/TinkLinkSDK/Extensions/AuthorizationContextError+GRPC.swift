import GRPC

extension AuthorizationContext.Error {
    init?(_ error: Swift.Error) {
        guard let status = error as? GRPC.GRPCStatus else { return nil }
        switch status.code {
        case .invalidArgument:
            self = .invalidRedirectURI(status.message ?? "")
        default:
            return nil
        }
    }
}
