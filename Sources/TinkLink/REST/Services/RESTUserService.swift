import Foundation

final class RESTUserService: UserService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    private var accessToken: AccessToken?

    func createAnonymous(market: Market?, locale: Locale, origin: String?, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        //TODO
        return nil
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable? {
        var request = RESTResourceRequest(path: "/link/v1/authentication/token", method: .post, contentType: .json, completion: completion)
        let body = ["code": code.rawValue]
        request.body = try? JSONEncoder().encode(body)

        if let accessToken = accessToken {
            request.headers = ["Authorization": "Bearer \(accessToken.rawValue)"]
        }

        return client.performRequest(request)
    }

    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        var request = RESTResourceRequest<RESTUser>(path: "/api/v1/user", method: .get, contentType: .json) { result in
            completion(result.map(UserProfile.init))
        }

        if let accessToken = accessToken {
            request.headers = ["Authorization": "Bearer \(accessToken.rawValue)"]
        }

        return client.performRequest(request)
    }
}

extension RESTUserService: TokenConfigurableService {
    func configure(_ accessToken: AccessToken) {
        self.accessToken = accessToken
    }
}
