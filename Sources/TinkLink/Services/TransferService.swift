import Foundation

protocol TransferService {
    func accounts(destinationUris: [Transfer.TransferEntityURI], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable?
    func transfer(transfer: Transfer, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable?
    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable?
}
