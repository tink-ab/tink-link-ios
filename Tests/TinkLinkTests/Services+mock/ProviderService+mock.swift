import Foundation
import GRPC
@testable import TinkLink

class MockedSuccessProviderService: ProviderService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

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

class MockedUnauthenticatedErrorProviderService: ProviderService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }
}
