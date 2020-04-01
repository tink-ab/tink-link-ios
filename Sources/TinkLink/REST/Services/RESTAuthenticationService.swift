import Foundation

final class RESTAuthenticationService: AuthenticationService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func clientDescription(clientID: String, scopes: [Scope], redirectURI: URL, completion: @escaping (Result<ClientDescription, Error>) -> Void) -> RetryCancellable? {

        let body = RESTDescribeOAuth2ClientRequest(clientId: clientID, redirectUri: redirectURI.absoluteString, scope: scopes.scopeDescription)

        let data = try? JSONEncoder().encode(body)

        let request = RESTResourceRequest<RESTDescribeOAuth2ClientResponse>(path: "/api/v1/oauth/describe", method: .post, body: data, contentType: .json, completion: { result in
            completion(result.map(ClientDescription.init))
        })

        return client.performRequest(request)
    }

    func authorize(clientID: String, redirectURI: URL, scopes: [Scope], completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) -> RetryCancellable? {

        let body = [
            "clientId": clientID,
            "redirectUri": redirectURI.absoluteString,
            "scope": scopes.scopeDescription,
        ]
        let data = try? JSONEncoder().encode(body)

        let request = RESTResourceRequest(path: "/api/v1/oauth/authorize", method: .post, body: data, contentType: .json, completion:  completion)

        return client.performRequest(request)
    }
}
