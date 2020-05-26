import Foundation
@testable import TinkLink

class MockedSuccessTransferService: TransferService {
    @discardableResult
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        completion(.success([Account.checkingTestAccount]))
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.accounts(destinationUris: destinationUris, completion: completion)
        }
    }

    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.success([Beneficiary.savingBeneficiary]))
        return nil
    }

    func transfer(transfer: Transfer, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}

class MockedUnauthenticatedErrorTransferService: TransferService {
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func transfer(transfer: Transfer, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }


}
