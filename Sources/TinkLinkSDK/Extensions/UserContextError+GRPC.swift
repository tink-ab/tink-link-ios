import Foundation
import GRPC

extension UserContext.Error {
    init?(_ error: Swift.Error) {
        guard let status = error as? GRPC.GRPCStatus else { return nil }
        switch status.code {
        case .invalidArgument:
            assertionFailure("Could not create temporary user:" + (status.message ?? "Invalid argument!"))
            self = .invalidMarketOrLocale(status.message ?? "")
        default:
            return nil
        }
    }
}
