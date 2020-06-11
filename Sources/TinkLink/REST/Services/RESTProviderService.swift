import Foundation

final class RESTProviderService: ProviderService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func providers(id: Provider.ID?, capabilities: Provider.Capabilities?, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {

        var parameters = [
            URLQueryItem(name: "includeTestProviders", value: includeTestProviders ? "true" : "false")
        ]

        if let id = id {
            parameters.append(.init(name: "name", value: id.value))
        }

        if let restCapabilities = capabilities?.restCapabilities, restCapabilities.count == 1 {
            parameters.append(.init(name: "capability", value: restCapabilities[0].rawValue))
        }

        let request = RESTResourceRequest<RESTProviders>(path: "/api/v1/providers", method: .get, contentType: .json, parameters: parameters) { result in

            do {
                var providers = try result.get().providers.map(Provider.init)

                if let capabilities = capabilities {
                    providers = providers.filter {
                        !$0.capabilities.isDisjoint(with: capabilities)
                    }
                }
                completion(.success(providers))
            } catch {
                completion(.failure(error))
            }
        }

        return client.performRequest(request)

    }
}
