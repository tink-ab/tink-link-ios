import Foundation

final class RESTTransferService {
    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func transfer(transfer: Transfer, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        let body = RESTTransferRequest(
            amount: transfer.amount.doubleValue,
            credentialsId: transfer.credentialsID.value,
            currency: transfer.currency.value,
            destinationMessage: transfer.destinationMessage,
            id: transfer.id.value,
            sourceMessage: transfer.sourceMessage,
            dueDate: transfer.dueDate,
            messageType: transfer.messageType.rawValue,
            destinationUri: transfer.destinationUri.value,
            sourceUri: transfer.sourceUri.value
        )
        let data = try? JSONEncoder().encode(body)

        let request = RESTResourceRequest<RESTSignableOperation>(path: "/api/v1/transfer", method: .post, body: data, contentType: .json) { result in
            let mappedResult = result.map{ SignableOperation($0) }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }

    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {

        let request = RESTResourceRequest<RESTSignableOperation>(path: "/api/v1/transfer/\(transferID.value)/status", method: .get, contentType: .json) { result in
            let mappedResult = result.map{ SignableOperation($0) }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }
}
