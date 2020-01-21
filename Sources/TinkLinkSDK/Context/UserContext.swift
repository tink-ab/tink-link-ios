import Foundation

/// An object that you use to create a user that will be used in other TinkLink APIs.
public final class UserContext {
    private let userService: UserService
    private var retryCancellable: RetryCancellable?

    /// Creates a context to register for an access token that will be used in other TinkLink APIs.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    public init(tinkLink: TinkLink = .shared) {
        self.userService = UserService(tinkLink: tinkLink)
    }

    /// Authenticate a permanent user with authorization code.
    ///
    /// - Parameter authorizationCode: Authenticate with a `AuthorizationCode` that delegated from Tink to exchanged for a user object.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func authenticateUser(authorizationCode: AuthorizationCode, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        return userService.authenticate(code: authorizationCode, completion: { result in
            do {
                let authenticateResponse = try result.get()
                let accessToken = authenticateResponse.accessToken
                completion(.success(User(accessToken: accessToken)))
            } catch {
                completion(.failure(error))
            }
        })
    }

    /// Authenticate a permanent user with accessToken.
    ///
    /// - Parameter accessToken: Authenticate with an accessToken `String` that generated for the permanent user.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func authenticateUser(accessToken: AccessToken, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        completion(.success(User(accessToken: accessToken)))
        return nil
    }


    /// Create a user for a specific market and locale.
    ///
    /// - Parameter market: Register a `Market` for creating the user, will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for creating the user, will use the default locale in TinkLink if nothing is provided.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    func createTemporaryUser(for market: Market, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        return userService.createAnonymous(market: market, locale: locale) { result in
            do {
                let accessToken = try result.get()
                completion(.success(User(accessToken: accessToken)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
