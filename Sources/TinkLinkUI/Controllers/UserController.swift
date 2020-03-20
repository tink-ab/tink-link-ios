import TinkLink
import Foundation

final class UserController {
    let tink: Tink
    
    var user: User?
    
    private lazy var userContext = UserContext(tink: tink)

    init(tink: Tink) {
        self.tink = tink
    }

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


    func createTemporaryUser(for market: Market, locale: Locale = Tink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) {
        userContext.createTemporaryUser(for: market, locale: locale) { [weak self] result in
            self?.user = try? result.get()
            completion(result)
        }
    }
}
