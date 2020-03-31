import Foundation

/// An object that you use to create a user that will be used in other TinkLink APIs.
public final class UserContext {
    private let userService: UserService & TokenConfigurableService
    private var retryCancellable: RetryCancellable?
    private let userContextClientBehaviors: ComposableClientBehavior = ComposableClientBehavior(behaviors: [AuthorizationHeaderClientBehavior(sessionCredential: nil)])

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
    public convenience init(tink: Tink = .shared) {
        self.init(userService: RESTUserService(client: tink.client))
    }

    init(userService: UserService & TokenConfigurableService) {
        self.userService = userService
    }

    // MARK: - Authenticating a User

    /// Authenticate a permanent user with authorization code.
    ///
    /// - Parameter authorizationCode: Authenticate with a `AuthorizationCode` that delegated from Tink to exchanged for a user object.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func authenticateUser(authorizationCode: AuthorizationCode, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
        return userService.authenticate(code: authorizationCode, contextClientBehaviors: userContextClientBehaviors, completion: { result in
            do {
                let authenticateResponse = try result.get()
                let accessToken = authenticateResponse.accessToken
                let user = User(accessToken: accessToken)
                self.userProfile(user, completion: completion)
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
        let user = User(accessToken: accessToken)
        return userProfile(user, completion: completion)
    }

    /// Create a user for a specific market and locale.
    ///
    /// - Parameter market: Register a `Market` for creating the user, will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for creating the user, will use the default locale in TinkLink if nothing is provided.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func createTemporaryUser(for market: Market, locale: Locale = Tink.defaultLocale, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
        return userService.createAnonymous(market: market, locale: locale, origin: nil, contextClientBehaviors: userContextClientBehaviors) { result in
            let mappedResult = result
                .map { User(accessToken: $0) }
                .mapError { Error(createTemporaryUserError: $0) ?? $0 }
            do {
                let user = try mappedResult.get()
                completion(.success(user))
            } catch Error.invalidMarketOrLocale(let message) {
                completion(.failure(Error.invalidMarketOrLocale(message)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    @discardableResult
    func userProfile(_ user: User, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
        userService.configure(user.accessToken)
        return userService.userProfile { result in
            do {
                let userProfile = try result.get()
                completion(.success(User(accessToken: user.accessToken, userProfile: userProfile)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
