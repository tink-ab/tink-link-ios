import Foundation
@testable import TinkLink

class MockTransferService: TransferService {
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        let testAccount = Account(accountNumber: "testNumber", balance: 200.0, credentialsID: Credentials.ID.init("testCredentialsID"), isFavored: false, id: Account.ID.init("testAccountID"), name: "testAccount", ownership: 1.0, kind: .checking, transferSourceIdentifiers: nil, transferDestinations: nil, details: nil, holderName: "test", isClosed: nil, flags: nil, accountExclusion: nil, currencyDenominatedBalance: CurrencyDenominatedAmount.init(value: 200.0, currencyCode: "EUR"), refreshed: nil, financialInstitutionID: Provider.FinancialInstitution.ID.init("testFinancialInstitutionID"))
        completion(.success([testAccount]))
        return nil
    }

    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
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
