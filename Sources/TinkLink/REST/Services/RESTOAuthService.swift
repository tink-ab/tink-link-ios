import Foundation

final class RESTOAuthService: OAuthService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func createAnonymous(market: Market?, locale: Locale, origin: String?, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {

        let body = RESTAnonymousUserRequest(market: market?.code ?? "", origin: origin, locale: locale.identifier)

        let request = RESTResourceRequest<RESTAnonymousUserResponse>(path: "/api/v1/user/anonymous", method: .post, body: body, contentType: .json) { (result) in

            completion(result.map { AccessToken($0.access_token) })
        }

        return client.performRequest(request)
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        let body = ["code": code.rawValue]
        let request = RESTResourceRequest<RESTAuthenticateResponse>(path: "/link/v1/authentication/token", method: .post, body: body, contentType: .json) { result in
            completion(result.map(\.accessToken).map(AccessToken.init(_:)))
        }

        return client.performRequest(request)
    }
}
