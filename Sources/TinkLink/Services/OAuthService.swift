import Foundation

protocol OAuthService {
    func createAnonymous(market: Market?, locale: Locale, origin: String?, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable?
    func authenticate(clientID: String, code: AuthorizationCode, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable?
}
