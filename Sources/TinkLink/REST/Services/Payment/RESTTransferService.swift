import Foundation

final class RESTTransferService {
    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    // TOOD: use mobile transfer model when creating the transfer
    func transfer(transfer: RESTTransferRequest, completion: @escaping (Result<RESTTransferResponse, Error>) -> Void) -> RetryCancellable? {
        let data = try? JSONEncoder().encode(transfer)

        let request = RESTResourceRequest<RESTTransferResponse>(path: "/api/v1/transfer", method: .post, body: data, contentType: .json) { result in
            // TODO: map to the mobile transfer response model
            completion(result)
        }

        return client.performRequest(request)
    }

    // TOOD: use mobile transfer model ID when getting the transfer status
    func transferStatus(transferID: String, completion: @escaping (Result<RESTTransferResponse, Error>) -> Void) -> RetryCancellable? {

        let request = RESTResourceRequest<RESTTransferResponse>(path: "/api/v1/transfer/\(transferID)/status", method: .get, contentType: .json) { result in
            // TODO: map to the mobile transfer response model
            completion(result)
        }

        return client.performRequest(request)
    }
}
