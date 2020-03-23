import Foundation

/// An object that you use to get user consent.
public final class ConsentContext {
    private let tink: Tink
    private let service: AuthenticationService

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
