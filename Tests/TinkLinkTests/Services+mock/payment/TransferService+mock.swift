import Foundation
@testable import TinkCore

class MockedSuccessTransferService: TransferService {
    private var signableOperation: SignableOperation?

    @discardableResult
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        completion(.success([Account.checkingTestAccount]))
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.accounts(destinationUris: destinationUris, completion: completion)
        }
    }

    @discardableResult
    func transfer(amount: Decimal, currency: CurrencyCode, credentialsID: Credentials.ID?, transferID: Transfer.ID?, sourceURI: String, destinationURI: String, sourceMessage: String?, destinationMessage: String, dueDate: Date?, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        signableOperation = SignableOperation.createdSignableOperation
        completion(.success(SignableOperation.createdSignableOperation))
        return nil
    }

    @discardableResult
    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        switch signableOperation?.status {
        case .created:
            signableOperation = SignableOperation.awaitingCredentialsSignableOperation
            completion(.success(SignableOperation.awaitingCredentialsSignableOperation))
        case .awaitingCredentials, .awaitingThirdPartyAppAuthentication, .executing:
            signableOperation = SignableOperation.executedSignableOperation
            completion(.success(SignableOperation.executedSignableOperation))
        default:
            break
        }
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.transferStatus(transferID: transferID, completion: completion)
        }
    }
}

class MockedCancelledTransferService: TransferService {
    private var signableOperation: SignableOperation?

    @discardableResult
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    @discardableResult
    func transfer(amount: Decimal, currency: CurrencyCode, credentialsID: Credentials.ID?, transferID: Transfer.ID?, sourceURI: String, destinationURI: String, sourceMessage: String?, destinationMessage: String, dueDate: Date?, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        signableOperation = SignableOperation.createdSignableOperation
        completion(.success(SignableOperation.createdSignableOperation))
        return nil
    }

    @discardableResult
    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        switch signableOperation?.status {
        case .created:
            signableOperation = SignableOperation.awaitingCredentialsSignableOperation
            completion(.success(SignableOperation.awaitingCredentialsSignableOperation))
        case .awaitingCredentials, .awaitingThirdPartyAppAuthentication, .executing:
            signableOperation = SignableOperation.cancelledSignableOperation
            completion(.success(SignableOperation.cancelledSignableOperation))
        default:
            break
        }
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.transferStatus(transferID: transferID, completion: completion)
        }
    }
}

class MockedUnauthenticatedErrorTransferService: TransferService {
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func transfer(amount: Decimal, currency: CurrencyCode, credentialsID: Credentials.ID?, transferID: Transfer.ID?, sourceURI: String, destinationURI: String, sourceMessage: String?, destinationMessage: String, dueDate: Date?, redirectURI: URL, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func transferStatus(transferID: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }
}
