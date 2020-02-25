import Foundation

/// An object that you use to create a user that will be used in other Tink APIs.
public final class UserContext {
    private let userService: UserService
    private var retryCancellable: RetryCancellable?

    /// Error that the `UserContext` can throw.
    public enum Error: Swift.Error {
        /// The market and/or locale was invalid. The payload from the backend can be found in the associated value.
        case invalidMarketOrLocale(String)

        init?(createTemporaryUserError error: Swift.Error) {
            switch error {
            case ServiceError.invalidArgument(let message):
                self = .invalidMarketOrLocale(message)
            default:
                return nil
            }
        }
    }

    // MARK: - Creating a Context

    /// Creates a context to register for an access token that will be used in other Tink APIs.
    /// - Parameter tink: Tink instance, will use the shared instance if nothing is provided.
    public init(tink: Tink = .shared) {
        self.userService = UserService(tink: tink)
    }

    // MARK: - Authenticating a User

    /// Authenticate a permanent user with authorization code.
    ///
    /// - Parameter authorizationCode: Authenticate with a `AuthorizationCode` that delegated from Tink to exchanged for a user object.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func authenticateUser(authorizationCode: AuthorizationCode, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
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
    public func authenticateUser(accessToken: AccessToken, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
        completion(.success(User(accessToken: accessToken)))
        return nil
    }

    /// Create a user for a specific market and locale.
    ///
    /// - Parameter market: Register a `Market` for creating the user, will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for creating the user, will use the default locale in Tink if nothing is provided.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    func createTemporaryUser(for market: Market, locale: Locale = Tink.defaultLocale, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
        return userService.createAnonymous(market: market, locale: locale) { result in
            let mappedResult = result
                .map { User(accessToken: $0) }
                .mapError { Error(createTemporaryUserError: $0) ?? $0 }
            do {
                let user = try mappedResult.get()
                completion(.success(user))
            } catch Error.invalidMarketOrLocale(let message) {
                assertionFailure("Could not create temporary user: " + message)
                completion(.failure(Error.invalidMarketOrLocale(message)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
