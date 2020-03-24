import Foundation

final class RESTAuthenticationService: AuthenticationService {

    private let client: RESTClient
    private let accessToken: AccessToken

    init(client: RESTClient, accessToken: AccessToken) {
        self.client = client
        self.accessToken = accessToken
    }

    func clientDescription(scopes: [Scope], redirectURI: URL, completion: @escaping (Result<ClientDescription, Error>) -> Void) -> RetryCancellable? {
        // Investigate: Do we have REST endpoint?
        return nil
    }

    func authorize(clientID: String, redirectURI: URL, scopes: [Scope], completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) -> RetryCancellable? {

        let body = [
            "clientId": clientID,
            "redirectUri": redirectURI.absoluteString,
            "scope": scopes.scopeDescription,
        ]
        let data = try? JSONEncoder().encode(body)

        var request = RESTResourceRequest(path: "/api/v1/oauth/authorize", method: .post, body: data, contentType: .json, completion:  completion)

        request.headers = ["Authorization" : "Bearer \(accessToken.rawValue)"]

        return client.performRequest(request)
    }
}
