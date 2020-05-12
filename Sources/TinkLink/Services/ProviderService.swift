import Dispatch

protocol ProviderService {
    func providers(id: Provider.ID?, capabilities: Provider.Capabilities?, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable?
}
