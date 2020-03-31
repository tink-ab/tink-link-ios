import Foundation

protocol UserService {
    func createAnonymous(market: Market?, locale: Locale, origin: String?, contextClientBehaviors: ComposableClientBehavior, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable?
    func authenticate(code: AuthorizationCode, contextClientBehaviors: ComposableClientBehavior, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable?
    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable?
}
