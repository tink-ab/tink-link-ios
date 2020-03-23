import Foundation

/// An object that you use to get user consent.
public final class ConsentContext {
    private let tink: Tink
    private let service: AuthenticationService

    /// Error that the `ConsentContext` can throw.
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
    /// - Parameter user: `User` that will be used for authorizing scope with the Tink API.
    public init(tink: Tink = .shared, user: User) {
        self.tink = tink
        self.service = AuthenticationService(tink: tink, accessToken: user.accessToken)
    }
}
