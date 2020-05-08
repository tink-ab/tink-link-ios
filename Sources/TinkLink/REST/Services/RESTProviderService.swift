import Foundation

final class RESTProviderService: ProviderService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func providers(id: Provider.ID?, capabilities: Provider.Capabilities?, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {

        var parameters = [
            (name: "includeTestProviders", value: includeTestProviders ? "true" : "false")
        ]

        if let id = id {
            parameters.append((name: "name", value: id.value))
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
