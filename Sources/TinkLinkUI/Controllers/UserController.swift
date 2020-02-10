import TinkLinkSDK
import Foundation

final class UserController {
    var user: User?
    
    private var userContext = UserContext()

    func authenticateUser(authorizationCode: AuthorizationCode, completion: @escaping (Result<User, Error>) -> Void) {
        userContext.authenticateUser(authorizationCode: authorizationCode) { [weak self] result in
            self?.user = try? result.get()
            completion(result)
        }
    }

    func authenticateUser(accessToken: AccessToken, completion: @escaping (Result<User, Error>) -> Void) {
        userContext.authenticateUser(accessToken: accessToken) { [weak self] result in
            self?.user = try? result.get()
            completion(result)
        }
    }

    func createTemporaryUser(for market: Market, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        userContext.createTemporaryUser(for: market, locale: locale) { [weak self] result in
            self?.user = try? result.get()
            completion(result)
        }
    }
}
