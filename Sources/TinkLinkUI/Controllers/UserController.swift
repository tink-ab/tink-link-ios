import TinkLinkSDK
import Foundation

final class UserController {
    let tinkLink: TinkLink
    
    var user: User?
    
    private lazy var userContext = UserContext(tinkLink: tinkLink)

    init(tinkLink: TinkLink) {
        self.tinkLink = tinkLink
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


    func createTemporaryUser(for market: Market, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) {
        userContext.createTemporaryUser(for: market, locale: locale) { [weak self] result in
            self?.user = try? result.get()
            completion(result)
        }
    }
}
