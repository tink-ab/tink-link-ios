import TinkLink
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
}
