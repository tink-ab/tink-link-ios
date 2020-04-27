import Foundation
@testable import TinkLink

class MockedSuccessProviderService: ProviderService {

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        let providers = [
            Provider.nordeaBankID,
            Provider.nordeaPassword,
            Provider.sparbankernaBankID,
            Provider.sparbankernaPassword,
            Provider.swedbankBankID,
            Provider.swedbankPassword
        ]
        completion(.success(providers))
        return nil
    }
}

class MockedUnauthenticatedErrorProviderService: ProviderService {

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }
}
