protocol BeneficiaryService {
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable?
    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
}
