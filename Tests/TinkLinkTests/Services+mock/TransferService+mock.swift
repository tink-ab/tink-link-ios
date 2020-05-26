import Foundation
@testable import TinkLink

class MockedSuccessTransferService: TransferService {
    @discardableResult
    func accounts(destinationUris: [URL], completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        let testAccount = Account(accountNumber: "testNumber", balance: 200.0, credentialsID: Credentials.ID("testCredentialsID"), isFavored: false, id: Account.ID("testAccountID"), name: "testAccount", ownership: 1.0, kind: .checking, transferSourceIdentifiers: nil, transferDestinations: nil, details: nil, holderName: "test", isClosed: nil, flags: nil, accountExclusion: nil, currencyDenominatedBalance: CurrencyDenominatedAmount(value: 200.0, currencyCode: "EUR"), refreshed: nil, financialInstitutionID: Provider.FinancialInstitution.ID("testFinancialInstitutionID"))
        completion(.success([testAccount]))
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.accounts(destinationUris: destinationUris, completion: completion)
        }
    }

    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        let testBeneficiary = Beneficiary(
            type: "test",
            name: "testBeneficiary",
            accountID: Account.ID("testAccountID"),
            accountNumber: "testNumber",
            uri: URL(string: "test://testBeneficiary")
        )
        completion(.success([testBeneficiary]))
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
