import Foundation

/// An object that accesses providers for a specific market and supports the grouping of providers.
public final class ProviderContext {
    /// Filter representing which providers a context should access.
    public struct Filter: Hashable {
        /// The capabilities that the providers have.
        public let capabilities: Provider.Capabilities
        /// The different kinds of providers that should be retreived.
        public let kinds: Set<Provider.Kind>
        /// The access types that should be retreived.
        public let accessTypes: Set<Provider.AccessType>

        /// Creates a set of filters that is used to determine which providers should be retreived by a `ProviderContext`.
        /// - Parameter capabilities: The capabilities that the providers have.
        /// - Parameter kinds: The different kind of providers that should be retreived.
        /// - Parameter accessTypes: The access types that should be retreived.
        public init(capabilities: Provider.Capabilities, kinds: Set<Provider.Kind>, accessTypes: Set<Provider.AccessType>) {
            self.capabilities = capabilities
            self.kinds = kinds
            self.accessTypes = accessTypes
        }

        /// A default filter that contain all capabilities, all non-test kinds and all access types.
        public static let `default` = Filter(capabilities: .all, kinds: .default, accessTypes: .all)
    }

    private let redirectURI: URL
    private let service: ProviderService

    // MARK: - Creating a Context

    /// Creates a `ProviderContext` bound to the provided `Tink` instance.
    ///
    /// - Parameter tink: `Tink` instance, will use the shared instance if nothing is provided.
    public convenience init(tink: Tink = .shared) {
        let service = tink.services.providerService
        self.init(tink: tink, providerService: service)
    }

    init(tink: Tink, providerService: ProviderService) {
        self.redirectURI = tink.configuration.redirectURI
        self.service = providerService
    }

    // MARK: - Fetching Providers

    /// Fetches providers matching the provided filter.
    ///
    /// Required scopes:
    /// - credentials:read
    ///
    /// - Parameter filter: Filter for providers to fetch.
    /// - Parameter completion: A result representing either a list of providers or an error.
    @discardableResult
    public func fetchProviders(filter: Filter = .default, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        return service.providers(name: nil, capabilities: filter.capabilities, includeTestProviders: filter.kinds.contains(.test), excludeNonTestProviders: filter.kinds == [.test]) { result in
            do {
                let fetchedProviders = try result.get()
                let filteredProviders = fetchedProviders.filter { filter.accessTypes.contains($0.accessType) && filter.kinds.contains($0.kind) }
                completion(.success(filteredProviders))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetching one specific provider

    /// Fetches a specific provider matching the provided name.
    ///
    /// Required scopes:
    /// - credentials:read
    ///
    /// - Parameter name: Name of provider to fetch.
    /// - Parameter completion: A result representing either a single provider or an error.
    @discardableResult
    public func fetchProvider(with name: Provider.Name, completion: @escaping (Result<Provider, Error>) -> Void) -> RetryCancellable? {
        return service.providers(name: name, capabilities: nil, includeTestProviders: true, excludeNonTestProviders: false) { result in
            do {
                let fetchedProviders = try result.get()
                if let provider = fetchedProviders.first {
                    completion(.success(provider))
                } else {
                    throw ServiceError.notFound("")
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
