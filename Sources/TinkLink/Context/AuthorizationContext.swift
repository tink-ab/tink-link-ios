import Foundation

/// An object that you use to authorize for a user with requested scopes.
public final class AuthorizationContext {
    private let clientID: String
    private let appURI: URL
    private let service: AuthenticationService

    /// Error that the `AuthorizationContext` can throw.
    public enum Error: Swift.Error {
        /// The scope or redirect URI was invalid.
        ///
        /// If you get this error make sure that your client has the scopes you're requesting and that you've added a valid redirect URI in Tink Console.
        ///
        /// - Note: The payload from the backend can be found in the associated value.
        case invalidScopeOrRedirectURI(String)

        init?(_ error: Swift.Error) {
            switch error {
            case ServiceError.invalidArgument(let message):
                self = .invalidScopeOrRedirectURI(message)
            default:
                return nil
            }
        }
    }

    // MARK: - Creating a Context

    /// Creates a context to authorize for an authorization code for a user with requested scopes.
    ///
    /// - Parameter tink: Tink instance, will use the shared instance if nothing is provided.
    public init(tink: Tink = .shared) {
        precondition(tink.configuration.appURI != nil, "Configure Tink by calling `Tink.configure(with:)` with a `appURI` configured.")
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
            if case .failure(Error.invalidScopeOrRedirectURI(let message)) = mappedResult {
                assertionFailure("Could not authorize: " + message)
            }
            completion(mappedResult)
        }
    }

    // MARK: - Getting Information About the Client

    /// Get a description of the client.
    ///
    /// - Parameter completion: The block to execute when the client description is received or if an error occurred.
    @discardableResult
    public func fetchClientDescription(completion: @escaping (Result<ClientDescription, Swift.Error>) -> Void) -> RetryCancellable? {
        let scopes: [Scope] = []
        return service.clientDescription(clientID: clientID, scopes: scopes, redirectURI: appURI) { result in
            let mappedResult = result.mapError { Error($0) ?? $0 }
            if case .failure(Error.invalidScopeOrRedirectURI(let message)) = mappedResult {
                assertionFailure("Could not get client description: " + message)
            }
            completion(mappedResult)
        }
    }
}
