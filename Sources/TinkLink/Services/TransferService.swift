import Foundation

protocol TransferService {
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable?
    func transfer(transfer: Transfer, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable?
    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable?
}
