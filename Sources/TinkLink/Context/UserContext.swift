import Foundation

/// An object that you use to create a user that will be used in other TinkLink APIs.
final class UserContext {
    private let oAuthService: OAuthService
    private let userService: UserService
    private var retryCancellable: RetryCancellable?
    private var tink: Tink?

    // MARK: - Creating a Context

    /// Creates a context to register for an access token that will be used in other Tink APIs.
    /// - Parameter tink: Tink instance, will use the shared instance if nothing is provided.
    public convenience init(tink: Tink = .shared) {
        self.init(
            oAuthService: RESTOAuthService(client: tink.client),
            userService: RESTUserService(client: tink.client)
        )
        self.tink = tink
    }

    init(oAuthService: OAuthService, userService: UserService) {
        self.oAuthService = oAuthService
        self.userService = userService
    }

    @discardableResult
    func fetchUserProfile(_ user: User, completion: @escaping (Result<User, Swift.Error>) -> Void) -> RetryCancellable? {
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
