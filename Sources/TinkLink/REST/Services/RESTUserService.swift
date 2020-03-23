import Foundation

final class RESTUserService: UserService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func createAnonymous(market: Market?, locale: Locale, origin: String?, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        //TODO
        return nil
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable? {
        var request = RESTResourceRequest(path: "/link/v1/authentication/token", method: .post, contentType: .json, completion: completion)
        let body = ["code": code.rawValue]
        request.body = try? JSONEncoder().encode(body)

        return client.performRequest(request)
    }

    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        let request = RESTResourceRequest<RESTUser>(path: "/api/v1/user", method: .get, contentType: .json) { result in
            completion(result.map(UserProfile.init))
        }
        return client.performRequest(request)
    }
}
