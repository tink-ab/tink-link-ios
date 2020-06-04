import Foundation
@testable import TinkLink

class MutableTransferService: TransferService {
    private var signableOperationsByTransferID: [Transfer.ID: SignableOperation] = [:]
    private var accounts: [Account]
    private var beneficiaries: [Beneficiary]

    init(accounts: [Account], beneficiaries: [Beneficiary]) {
        self.accounts = accounts
        self.beneficiaries = beneficiaries
    }

    @discardableResult
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        completion(.success(accounts))
        return nil
    }

    @discardableResult
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.success(beneficiaries))
        return nil
    }

    @discardableResult
    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    @discardableResult
    func transfer(transfer: Transfer, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        let transferID = transfer.id ?? Transfer.ID(UUID().uuidString)
        let signableOperation = SignableOperation.makeSignableOperation(
            status: .created,
            credentialsID: transfer.credentialsID!,
            transferID: transferID,
            userID: User.ID(UUID().uuidString)
        )
        signableOperationsByTransferID[transferID] = signableOperation
        completion(.success(signableOperation))
        return nil
    }

    @discardableResult
    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        if let signableOperation = signableOperationsByTransferID[transferID] {
            completion(.success(signableOperation))
        } else {
            completion(.failure(ServiceError.notFound("No signable operation for transfer with id: \(transferID.value)")))
        }
        return nil
    }
}
