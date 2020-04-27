import Foundation

/// Represents which endpoints TinkLink will use.
public enum Environment {
    /// The production environment.
    case production
    /// A custom environment.
    /// - grpcURL: The URL for the gRPC endpoints
    /// - restURL: The URL for the REST endpoints
    case custom(restURL: URL)

    var restURL: URL {
        switch self {
        case .production:
            return URL(string: "https://api.tink.com")!
        case .custom(let url):
            return url
        }
    }
}
