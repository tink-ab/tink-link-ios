import Foundation

// MARK: - Tink Link Configuration
extension Tink {
    /// Configuration used to set up the TinkLink
    public struct Configuration {
        /// The client id for your app.
        public var clientID: String

        /// The URI you've setup in Console.
        public var redirectURI: URL

        /// The environment to use.
        public var environment: Environment

        /// Certificate to use with gRPC API.
        public var grpcCertificateURL: URL?

        /// Certificate to use with REST API.
        public var restCertificateURL: URL?

        /// - Parameters:
        ///   - clientID: The client id for your app.
        ///   - redirectURI: The URI you've setup in Console.
        ///   - environment: The environment to use, defaults to production.
        ///   - grpcCertificateURL: URL to a certificate file to use with gRPC API.
        ///   - restCertificateURL: URL to a certificate file to use with REST API.
        public init(
            clientID: String,
            redirectURI: URL,
            environment: Environment = .production,
            grpcCertificateURL: URL? = nil,
            restCertificateURL: URL? = nil
        ) throws {
            guard let host = redirectURI.host, !host.isEmpty else {
                throw NSError(domain: URLError.errorDomain, code: URLError.cannotFindHost.rawValue)
            }
            self.clientID = clientID
            self.redirectURI = redirectURI
            self.environment = environment
            self.grpcCertificateURL = grpcCertificateURL
            self.restCertificateURL = restCertificateURL
        }
    }
}

extension Tink.Configuration {
    enum Error: Swift.Error, LocalizedError {
        case clientIDNotFound
        case redirectURINotFound

        var errorDescription: String? {
            switch self {
            case .clientIDNotFound:
                return "`TINK_CLIENT_ID` was not found in environment variable. Please configure a Tink Link client identifer before using it."
            case .redirectURINotFound:
                return "`TINK_REDIRECT_URI` was not found in environment variable. Please configure a Tink Link redirect URI before using it."
            }
        }
    }

    init(processInfo: ProcessInfo) throws {
        guard let clientID = processInfo.tinkClientID else { throw Error.clientIDNotFound }
        guard let redirectURI = processInfo.tinkRedirectURI else { throw Error.redirectURINotFound }
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.environment = processInfo.tinkEnvironment ?? .production
        self.grpcCertificateURL = processInfo.tinkGrpcCertificateURL
        self.restCertificateURL = processInfo.tinkRestCertificateURL
    }
}
