import Foundation
import GRPC
@testable import TinkLink

class MockedSuccessProviderService: ProviderService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        let providers = [
            MockedProvider.nordeaBankID,
            MockedProvider.nordeaPassword,
            MockedProvider.sparbankernaBankID,
            MockedProvider.sparbankernaPassword,
            MockedProvider.swedbankBankID,
            MockedProvider.swedbankPassword
        ]
        completion(.success(providers))
        return nil
    }
}

class MockedUnauthenticatedErrorProviderService: ProviderService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }
}
