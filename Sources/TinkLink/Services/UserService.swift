import Foundation
import GRPC

protocol UserService {
    func createAnonymous(market: Market?, locale: Locale, origin: String?, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable?
    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable?
    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable?
}
