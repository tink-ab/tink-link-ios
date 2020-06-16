import Foundation

final class RESTTransferService: TransferService {
    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        let parameters: [URLQueryItem] = destinationUris.map { URLQueryItem(name: "destination[]", value: $0.absoluteString) }

        let request = RESTResourceRequest<RESTAccountListResponse>(path: "/api/v1/transfer/accounts", method: .get, contentType: .json, parameters: parameters) { result in
            let mappedResult = result.map { $0.accounts.map { Account(restAccount: $0) } }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }

    func transfer(transfer: Transfer, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        let body = RESTTransferRequest(
            amount: NSDecimalNumber(decimal: transfer.amount).doubleValue,
            credentialsId: transfer.credentialsID?.value,
            currency: transfer.currency.value,
            destinationMessage: transfer.destinationMessage,
            id: transfer.id?.value,
            sourceMessage: transfer.sourceMessage,
            dueDate: transfer.dueDate,
            messageType: nil,
            destinationUri: transfer.destinationUri,
            sourceUri: transfer.sourceUri,
            redirectUri: redirectURI.absoluteString
        )
        let request = RESTResourceRequest<RESTSignableOperation>(path: "/api/v1/transfer", method: .post, body: body, contentType: .json) { result in
            let mappedResult = result.map { SignableOperation($0) }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }

    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        let request = RESTResourceRequest<RESTSignableOperation>(path: "/api/v1/transfer/\(transferID.value)/status", method: .get, contentType: .json) { result in
            let mappedResult = result.map { SignableOperation($0) }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }
}
