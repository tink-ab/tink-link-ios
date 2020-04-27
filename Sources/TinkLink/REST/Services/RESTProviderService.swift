import Foundation

final class RESTProviderService: ProviderService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {

        let parameters = [(name: "includeTestProviders", value: includeTestProviders ? "true" : "false")]

        let request = RESTResourceRequest<RESTProviders>(path: "/api/v1/providers", method: .get, contentType: .json, parameters: parameters) { result in

            let result = result.map { $0.providers.map(Provider.init).filter { !$0.capabilities.isDisjoint(with: capabilities) } }

            completion(result)
        }

        return client.performRequest(request)

    }
}
