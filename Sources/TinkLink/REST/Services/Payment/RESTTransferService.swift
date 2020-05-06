import Foundation

final class RESTTransferService {
    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    // TOOD: use mobile transfer model when creating the transfer
    func transfer(transfer: Transfer, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        let body = RESTTransferRequest(
            amount: transfer.amount.doubleValue,
            credentialsId: transfer.credentialsID.value,
            currency: transfer.currency.value,
            sourceMessage: transfer.sourceMessage,
            destinationMessage: transfer.destinationMessage,
            id: transfer.id.value,
            dueDate: transfer.dueDate,
            messageType: transfer.messageType.rawValue,
            sourceUri: transfer.sourceUri.value,
            destinationUri: transfer.destinationUri.value)
        let data = try? JSONEncoder().encode(body)

        let request = RESTResourceRequest<RESTSignableOperation>(path: "/api/v1/transfer", method: .post, body: data, contentType: .json) { result in
            let mappedResult = result.map{ SignableOperation($0) }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }

    // TOOD: use mobile transfer model ID when getting the transfer status
    func transferStatus(transferID: String, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {

        let request = RESTResourceRequest<RESTSignableOperation>(path: "/api/v1/transfer/\(transferID)/status", method: .get, contentType: .json) { result in
            let mappedResult = result.map{ SignableOperation($0) }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }
}
