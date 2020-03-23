import Foundation

final class RESTUserService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    @discardableResult
    func userProfile(
        completion: @escaping (Result<RESTUserProfile, Error>) -> Void
    ) -> Cancellable? {
        let request = RESTResourceRequest(path: "/api/v1/user/profile", method: .get, contentType: .json, completion: completion)
        return client.performRequest(request)
    }

    @discardableResult
    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> Cancellable? {
        var request = RESTResourceRequest(path: "/link/v1/authentication/token", method: .post, contentType: .json, completion: completion)
        let body = ["code": code.rawValue]
        request.body = try? JSONEncoder().encode(body)

        return client.performRequest(request)
    }
}
