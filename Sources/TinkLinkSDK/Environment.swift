import Foundation

/// Represents which endpoints TinkLink will use.
public enum Environment {
    /// The production environment.
    case production
    /// A custom environment.
    /// - grpcURL: The URL for the gRPC endpoints
    /// - restURL: The URL for the REST endpoints
    case custom(grpcURL: URL, restURL: URL)

    var grpcURL: URL {
        switch self {
        case .production:
            return URL(string: "https://main-grpc.production.oxford.tink.se:443")!
        case .custom(let url, _):
            return url
        }
    }

    var restURL: URL {
        switch self {
        case .production:
            return URL(string: "https://api.tink.com")!
        case .custom(_, let url):
            return url
        }
    }
}
