extension ProviderContext {
    @available(*, deprecated, renamed: "Filter")
    public typealias Attributes = Filter

    @available(*, deprecated, renamed: "fetchProviders(filter:completion:)")
    public func fetchProviders(attributes: Filter = .default, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        return fetchProviders(filter: attributes, completion: completion)
    }
}
