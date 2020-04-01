import Foundation
@testable import TinkLink

class MockedAuthenticationService: AuthenticationService {
    func clientDescription(clientID: String, scopes: [Scope], redirectURI: URL, completion: @escaping (Result<ClientDescription, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
    func authorize(clientID: String, redirectURI: URL, scopes: [Scope], completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}
