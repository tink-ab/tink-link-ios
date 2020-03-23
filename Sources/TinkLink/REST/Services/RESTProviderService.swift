import Foundation

final class RESTProviderService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func providers(capabilities: Set<RESTProvider.Capabilities>? = nil, includeTestProviders: Bool = false, completion: @escaping (Result<[RESTProvider], Error>) -> Void) -> Cancellable? {

        let parameters = ["includeTestProviders": includeTestProviders ? "true" : "false"]

        let request = RESTResourceRequest<RESTProviders>(path: "/api/v1/providers", method: .get, contentType: .json, parameters: parameters) { result in

            //TODO: This is ugly
            var result = result.map { $0.providers }
            if let capabilities = capabilities {
                result = result.map { $0.filter { !capabilities.intersection($0.capabilities).isEmpty } }
            }
            completion(result)
        }

        return client.performRequest(request)

    }
}
