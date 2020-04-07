import Dispatch

protocol ProviderService {
    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable?
}
