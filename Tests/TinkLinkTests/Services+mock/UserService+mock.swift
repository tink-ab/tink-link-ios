import Foundation
import GRPC
@testable import TinkLink

class MockedSuccessUserService: UserService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

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

class MockedInvalidArgumentFailurefulUserService: UserService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()
    
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

class MockedUnauthenticatedErrorUserService: UserService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

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
