import Foundation
import TinkCore

class MutableTransferService: TransferService {
    private var signableOperationsByTransferID: [Transfer.ID: SignableOperation] = [:]
    private var accounts: [Account]

    init(accounts: [Account]) {
        self.accounts = accounts
    }

    @discardableResult
    func accounts(destinationURIs: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        completion(.success(accounts))
        return nil
    }

    @discardableResult
    func transfer(amount: Decimal, currency: CurrencyCode, credentialsID: Credentials.ID?, transferID: Transfer.ID?, sourceURI: String, destinationURI: String, sourceMessage: String?, destinationMessage: String, dueDate: Date?, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        let transferID = transferID ?? Transfer.ID(UUID().uuidString)
        let signableOperation = SignableOperation.makeSignableOperation(
            status: .created,
            credentialsID: credentialsID!,
            transferID: transferID,
            userID: User.ID(UUID().uuidString)
        )
        signableOperationsByTransferID[transferID] = signableOperation
        completion(.success(signableOperation))
        return nil
    }

    @discardableResult
    func transferStatus(id: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        if let signableOperation = signableOperationsByTransferID[id] {
            completion(.success(signableOperation))
        } else {
            completion(.failure(ServiceError.notFound("No signable operation for transfer with id: \(id.value)")))
        }
        return nil
    }
}
