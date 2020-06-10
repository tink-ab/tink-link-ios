import Foundation
@testable import TinkLink

class MockedSuccessBeneficiaryService: BeneficiaryService {
    @discardableResult
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.success([Beneficiary.savingBeneficiary]))
        return nil
    }

    @discardableResult
    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }
}

class MockedCancelledBeneficiaryService: BeneficiaryService {
    @discardableResult
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }
}



class MockedUnauthenticatedErrorBeneficiaryService: BeneficiaryService {
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }
}

class MockedBadRequestErrorBeneficiaryService: BeneficiaryService {
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.invalidArgumentError))
        return nil
    }

    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.invalidArgumentError))
        return nil
    }
}
