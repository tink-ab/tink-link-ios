import Foundation
@testable import TinkLink

class MockedSuccessOAuthService: OAuthService {
    func createAnonymous(market: Market?, locale: Locale, origin: String?, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        completion(.success(AccessToken("accessToken")))
        return nil
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable? {
        let authenticateResponse = AuthenticateResponse(accessToken: AccessToken("accessToken"))
        completion(.success(authenticateResponse))
        return nil
    }

    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        completion(.success(UserProfile(username: "test-user", nationalID: "test-id")))
        return nil
    }
}

class MockedInvalidArgumentFailurefulOAuthService: OAuthService {
    
    func createAnonymous(market: Market? = nil, locale: Locale, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.invalidArgumentError))
        return nil
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.invalidArgumentError))
        return nil
    }

    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.invalidArgumentError))
        return nil
    }
}

class MockedUnauthenticatedErrorOAuthService: OAuthService {

    func createAnonymous(market: Market? = nil, locale: Locale, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }
}
