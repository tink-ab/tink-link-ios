import Foundation
// This type represents a tree structure of providers.
///
/// This tree eventually leads to a leaf of type `Provider` that contains more detailed data about a provider.
public struct ProviderTree {
    public let financialInstitutionGroups: [FinancialInstitutionGroupNode]
    
    public init(providers: [Provider]) {
        self.financialInstitutionGroups = Dictionary(grouping: providers, by: { $0.groupDisplayName.isEmpty ? $0.financialInstitution.id.value : $0.groupDisplayName })
            .sorted(by: { $0.key < $1.key })
            .map { FinancialInstitutionGroupNode(providers: $0.value) }
    }
    
    public func makeFinancialInstitutions() -> [FinancialInstitutionNode] {
        let institutions: [FinancialInstitutionNode] = financialInstitutionGroups.flatMap { node -> [FinancialInstitutionNode] in
            switch node {
            case .accessTypes(let accessType):
                return [FinancialInstitutionNode(providers: accessType.flatMap { $0.providers }) ]
            case .credentialKinds(let kinds):
                return [FinancialInstitutionNode(providers: kinds.map { $0.provider })]
            case .provider(let provider):
                return [FinancialInstitutionNode(providers: [provider])]
            case .financialInstitutions(let nodes):
                return nodes
            }
        }
        return institutions
    }

    /// A parent node of the tree structure, with a `Provider` as it's leaf node.
    public struct CredentialKindNode {
        /// A unique identifier of a `CredentialKindNode`.
        public struct ID: Hashable, ExpressibleByStringLiteral {
            public init(stringLiteral value: String) {
                self.value = value
            }

            public init(_ value: String) {
                self.value = value
            }

            public let value: String
        }

        public var id: ID { ID(provider.id.value) }

        public let provider: Provider

        public var credentialKind: Credential.Kind { provider.credentialKind }

        public var displayDescription: String { provider.displayDescription.isEmpty ? provider.credentialKind.description : provider.displayDescription }

        public var imageURL: URL? { provider.image }
    }

    /// A parent node of the tree structure, with a list of either `CredentialKindNode` children or a single `Provider`.
    public enum AccessTypeNode {
        /// A unique identifier of a `AccessTypeNode`.
        public struct ID: Hashable, ExpressibleByStringLiteral {
            public init(stringLiteral value: String) {
                self.value = value
            }

            public init(_ value: String) {
                self.value = value
            }

            public let value: String
        }

        case provider(Provider)
        case credentialKinds([CredentialKindNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                self = .credentialKinds(providers.map(CredentialKindNode.init(provider:)).sorted(by: { $0.credentialKind.description < $1.credentialKind.description }))
            }
        }

        public var id: ID { ID(significantProvider.id.value) }

        public var providers: [Provider] {
            switch self {
            case .credentialKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        fileprivate var firstProvider: Provider {
            switch self {
            case .credentialKinds(let nodes):
                return nodes[0].provider
            case .provider(let provider):
                return provider
            }
        }

        fileprivate var significantProvider: Provider {
            switch self {
            case .credentialKinds(let nodes):
                return (nodes.first { $0.imageURL != nil })?.provider ?? firstProvider
            case .provider(let provider):
                return provider
            }
        }

        public var accessType: Provider.AccessType { firstProvider.accessType }

        public var imageURL: URL? { significantProvider.image }
    }

    /// A parent node of the tree structure, with a list of either `AccessTypeNode`, `CredentialKindNode` children or a single `Provider`.
    public enum FinancialInstitutionNode {
        /// A unique identifier of a `FinancialInstitutionNode`.
        public struct ID: Hashable, ExpressibleByStringLiteral {
            public init(stringLiteral value: String) {
                self.value = value
            }

            public init(_ value: String) {
                self.value = value
            }

            public let value: String
        }

        case provider(Provider)
        case credentialKinds([CredentialKindNode])
        case accessTypes([AccessTypeNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                    self = .credentialKinds(providers.map(CredentialKindNode.init(provider:)))
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(AccessTypeNode.init(providers:)).sorted { $0.accessType.description < $1.accessType.description }
                    self = .accessTypes(providersGroupedByAccessType)
                }
            }
        }

        public var id: ID { ID(significantProvider.id.value) }

        public var providers: [Provider] {
            switch self {
            case .accessTypes(let nodes):
                return nodes.flatMap { $0.providers }
            case .credentialKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        fileprivate var firstProvider: Provider {
            switch self {
            case .accessTypes(let accessTypeGroups):
                return accessTypeGroups[0].firstProvider
            case .credentialKinds(let groups):
                return groups[0].provider
            case .provider(let provider):
                return provider
            }
        }

        fileprivate var significantProvider: Provider {
            switch self {
            case .accessTypes(let accessTypeGroups):
                return (accessTypeGroups.first { $0.imageURL != nil})?.significantProvider ?? firstProvider
            case .credentialKinds(let groups):
                return (groups.first { $0.imageURL != nil })?.provider ?? firstProvider
            case .provider(let provider):
                return provider
            }
        }

        public var financialInstitution: Provider.FinancialInstitution { firstProvider.financialInstitution }

        public var imageURL: URL? { significantProvider.image }
    }

    /// A parent node of the tree structure, with a list of either `FinancialInstitutionNode`, `AccessTypeNode`, `CredentialKindNode` children or a single `Provider`.
    public enum FinancialInstitutionGroupNode: Identifiable {
        /// A unique identifier of a `FinancialInstitutionGroupNode`.
        public struct ID: Hashable, ExpressibleByStringLiteral {
            public init(stringLiteral value: String) {
                self.value = value
            }

            public init(_ value: String) {
                self.value = value
            }

            public let value: String
        }

        case provider(Provider)
        case credentialKinds([CredentialKindNode])
        case accessTypes([AccessTypeNode])
        case financialInstitutions([FinancialInstitutionNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByFinancialInstitution = Dictionary(grouping: providers, by: { $0.financialInstitution })
                if providersGroupedByFinancialInstitution.count == 1, let providers = providersGroupedByFinancialInstitution.values.first {
                    let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                    if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                        self = .credentialKinds(providers.map(CredentialKindNode.init(provider:)))
                    } else {
                        let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(AccessTypeNode.init(providers:))
                        self = .accessTypes(providersGroupedByAccessType)
                    }
                } else {
                    let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitution.values.map(FinancialInstitutionNode.init(providers:)).sorted { $0.financialInstitution.name < $1.financialInstitution.name }
                    self = .financialInstitutions(providersGroupedByFinancialInstitution)
                }
            }
        }

        public var id: ID { ID(significantProvider.id.value) }

        public var providers: [Provider] {
            switch self {
            case .financialInstitutions(let nodes):
                return nodes.flatMap { $0.providers }
            case .accessTypes(let nodes):
                return nodes.flatMap { $0.providers }
            case .credentialKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        private var firstProvider: Provider {
            switch self {
            case .financialInstitutions(let nodes):
                return nodes[0].firstProvider
            case .accessTypes(let nodes):
                return nodes[0].firstProvider
            case .credentialKinds(let nodes):
                return nodes[0].provider
            case .provider(let provider):
                return provider
            }
        }

        private var significantProvider: Provider {
            switch self {
            case .financialInstitutions(let nodes):
                return (nodes.first { $0.imageURL != nil })?.significantProvider ?? firstProvider
            case .accessTypes(let accessTypeGroups):
                return (accessTypeGroups.first { $0.imageURL != nil})?.significantProvider ?? firstProvider
            case .credentialKinds(let groups):
                return (groups.first { $0.imageURL != nil })?.provider ?? firstProvider
            case .provider(let provider):
                return provider
            }
        }

        public var displayName: String {
            if significantProvider.groupDisplayName.isEmpty {
                return significantProvider.financialInstitution.name
            } else {
                return significantProvider.groupDisplayName
            }
        }

        public var imageURL: URL? { significantProvider.image }
    }
}

extension Array where Element == ProviderTree.FinancialInstitutionGroupNode {
    public func makeFinancialInstitutions() -> [ProviderTree.FinancialInstitutionNode] {
        let institutions: [ProviderTree.FinancialInstitutionNode] = self.flatMap { node -> [ProviderTree.FinancialInstitutionNode] in
            switch node {
            case .accessTypes(let accessType):
                return [ProviderTree.FinancialInstitutionNode(providers: accessType.flatMap { $0.providers }) ]
            case .credentialKinds(let kinds):
                return [ProviderTree.FinancialInstitutionNode(providers: kinds.map { $0.provider })]
            case .provider(let provider):
                return [ProviderTree.FinancialInstitutionNode(providers: [provider])]
            case .financialInstitutions(let nodes):
                return nodes
            }
        }
        return institutions
    }
}
