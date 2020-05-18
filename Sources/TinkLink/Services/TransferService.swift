import Foundation

protocol TransferService {
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable?
    func beneficiary(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable?
    func transfer(transfer: Transfer, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable?
    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable?
}
