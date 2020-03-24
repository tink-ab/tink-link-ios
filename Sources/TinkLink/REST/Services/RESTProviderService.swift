import Foundation

final class RESTProviderService: ProviderService {

    private let client: RESTClient

    private var accessToken: AccessToken

    init(client: RESTClient, accessToken: AccessToken) {
        self.client = client
        self.accessToken = accessToken
    }

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {

        let parameters = ["includeTestProviders": includeTestProviders ? "true" : "false"]

        var request = RESTResourceRequest<RESTProviders>(path: "/api/v1/providers", method: .get, contentType: .json, parameters: parameters) { result in

            let result = result.map { $0.providers.map(Provider.init).filter { !$0.capabilities.isDisjoint(with: capabilities) } }

            completion(result)
        }

        request.headers = ["Authorization":"Bearer \(accessToken.rawValue)"]

        return client.performRequest(request)

    }
}
