import Foundation

protocol BeneficiaryService {
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable?
    func addBeneficiary(request: CreateBeneficiaryRequest, appURI: URL, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
}
