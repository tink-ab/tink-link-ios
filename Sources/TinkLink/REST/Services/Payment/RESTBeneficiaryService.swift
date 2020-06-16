import Foundation

class RESTBeneficiaryService: BeneficiaryService {
    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        let request = RESTResourceRequest<RESTBeneficiaryListResponse>(path: "/api/v1/beneficiaries", method: .get, contentType: .json) { result in
            let mappedResult = result.map { $0.beneficiaries.map { Beneficiary(restBeneficiary: $0) } }
            completion(mappedResult)
        }

        return client.performRequest(request)
    }

    func addBeneficiary(request: CreateBeneficiaryRequest, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        let body = RESTCreateBeneficiaryRequest(
            accountNumberType: request.accountNumberType,
            accountNumber: request.accountNumber,
            name: request.name,
            ownerAccountId: request.ownerAccountID.value,
            credentialsId: request.credentialsID.value
        )
        let request = RESTSimpleRequest(path: "/api/v1/beneficiaries", method: .post, body: body, contentType: .json) { result in
            completion(result.map { _ in })
        }
        return client.performRequest(request)
    }
}
