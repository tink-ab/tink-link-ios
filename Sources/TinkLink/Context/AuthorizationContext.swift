import Foundation

/// An object that you use to authorize for a user with requested scopes.
public final class AuthorizationContext {
    private let clientID: String
    private let appURI: URL
    private let service: AuthenticationService

    /// Error that the `AuthorizationContext` can throw.
    public struct Error: Swift.Error, Equatable, CustomStringConvertible {
        private enum Code: Int {
            case invalidScopeOrRedirectURI = 1
        }

        private let code: Code
        public let message: String

        private init(code: Code, message: String) {
            self.code = code
            self.message = message
        }

        public var description: String {
            return "AuthorizationContext.Error.\(String(describing: self.code))"
        }

        /// The scope or redirect URI was invalid.
        ///
        /// If you get this error make sure that your client has the scopes you're requesting and that you've added a valid redirect URI in Tink Console.
        ///
        /// - Note: The payload from the backend can be found in the associated value.
        public static let invalidScopeOrRedirectURI: Error = .init(code: .invalidScopeOrRedirectURI, message: "")

        init?(_ error: Swift.Error) {
            switch error {
            case ServiceError.invalidArgument(let message):
                self = .init(code: .invalidScopeOrRedirectURI, message: message)
            default:
                return nil
            }
        }

        static func ~=(lhs: Self, rhs: Swift.Error) -> Bool {
            return lhs.code == (rhs as? AuthorizationContext.Error)?.code
        }
    }

    // MARK: - Creating a Context

    /// Creates an `AuthorizationContext` bound to the provided Tink instance.
    ///
    /// - Parameter tink: The `Tink` instance to use. Will use the shared instance if nothing is provided.
    public init(tink: Tink = .shared) {
        precondition(tink.configuration.appURI != nil, "Configure Tink by calling `Tink.configure(with:)` with a `redirectURI` configured.")
        self.appURI = tink.configuration.appURI!
        self.clientID = tink.configuration.clientID
        self.service = tink.services.authenticationService
    }

    // MARK: - Authorizing a User

    /// Creates an authorization code with the requested scopes for the current user
    ///
    /// Once you have received the authorization code, you can exchange it for an access token on your backend and use the access token to access the user's data.
    /// Exchanging the authorization code for an access token requires the use of the client secret associated with your client identifier.
    ///
    /// - Parameter scope: A `Tink.Scope` list of OAuth scopes to be requested.
    ///                    The Scope array should never be empty.
    /// - Parameter completion: The block to execute when the authorization is complete.
    /// - Parameter result: Represents either an authorization code if authorization was successful or an error if authorization failed.
    @discardableResult
    public func _authorize(scopes: [Scope], completion: @escaping (_ result: Result<AuthorizationCode, Swift.Error>) -> Void) -> RetryCancellable? {
        return service.authorize(clientID: clientID, redirectURI: appURI, scopes: scopes) { result in
            let mappedResult = result.mapError { Error($0) ?? $0 }
            if case .failure(let error) = mappedResult, let authorizationError = error as? Error, case .invalidScopeOrRedirectURI = authorizationError {
                assertionFailure("Could not authorize: " + authorizationError.message)
            }
            completion(mappedResult)
        }
    }

    // MARK: - Getting Information About the Client

    /// Get a description of the client. This contains information about the name of the client, if it is an aggregator and what scopes the client has.
    ///
    /// - Parameter completion: The block to execute when the client description is received or if an error occurred.
    /// - Parameter result: Represents either the client description or an error if the fetch failed.
    @discardableResult
    public func fetchClientDescription(completion: @escaping (_ result: Result<ClientDescription, Swift.Error>) -> Void) -> RetryCancellable? {
        let scopes: [Scope] = []
        return service.clientDescription(clientID: clientID, scopes: scopes, redirectURI: appURI) { result in
            let mappedResult = result.mapError { Error($0) ?? $0 }
            if case .failure(let error) = mappedResult, let authorizationError = error as? Error, case .invalidScopeOrRedirectURI = authorizationError {
                assertionFailure("Could not get client description: " + authorizationError.message)
            }
            completion(mappedResult)
        }
    }
}
