import Foundation

/// An object that accesses providers for a specific market and supports the grouping of providers.
public final class ProviderContext {
    /// Attributes representing which providers a context should access.
    public struct Attributes: Hashable {
        /// The capabilities that the providers have.
        public let capabilities: Provider.Capabilities
        /// The different kinds of providers that should be retreived.
        public let kinds: Set<Provider.Kind>
        /// The access types that should be retreived.
        public let accessTypes: Set<Provider.AccessType>

        /// Creates a set of attributes that is used to determine which providers should be retreived by a `ProviderContext`.
        /// - Parameter capabilities: The capabilities that the providers have.
        /// - Parameter kinds: The different kind of providers that should be retreived.
        /// - Parameter accessTypes: The access types that should be retreived.
        public init(capabilities: Provider.Capabilities, kinds: Set<Provider.Kind>, accessTypes: Set<Provider.AccessType>) {
            self.capabilities = capabilities
            self.kinds = kinds
            self.accessTypes = accessTypes
        }

        /// A default set of atttributes that contain all capabilities, all non-test kinds and all access types.
        public static let `default` = Attributes(capabilities: .all, kinds: .excludingTest, accessTypes: .all)
    }

    private let tinkLink: TinkLink
    private let service: ProviderService
    private let user: User

    /// Creates a context to access providers that matches the provided attributes.
    /// 
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter user: `User` that will be used for fetching providers with the Tink API.
    public init(tinkLink: TinkLink = .shared, user: User) {
        self.user = user
        self.tinkLink = tinkLink
        self.service = ProviderService(tinkLink: tinkLink, accessToken: user.accessToken)
    }

    /// Fetches providers matching the provided attributes.
    ///
    /// - Parameter attributes: Attributes for providers to fetch
    /// - Parameter completion: A result representing either a list of providers or an error.
    @discardableResult
    public func fetchProviders(attributes: Attributes = .default, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        return service.providers(capabilities: attributes.capabilities, includeTestProviders: attributes.kinds.contains(.test)) { result in
            do {
                let fetchedProviders = try result.get()
                let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
                completion(.success(filteredProviders))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
