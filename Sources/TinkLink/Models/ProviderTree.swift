import Foundation

/// Use the `ProviderTree` to group providers by financial institution, access type and credentials kind.
///
/// You initialize a `ProviderTree` with a list of providers.
///
/// ```swift
/// let providerTree = ProviderTree(providers: <#T##Providers#>)
/// ```
///
/// Handle selection of a provider group by switching on the group to decide which screen should be shown next.
///
/// ```swift
/// override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
///     let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
///     switch financialInstitutionGroupNode {
///     case .financialInstitutions(let financialInstitutionGroups):
///         showFinancialInstitution(for: financialInstitutionGroups)
///     case .accessTypes(let accessTypeGroups):
///         showAccessTypePicker(for: accessTypeGroups)
///     case .credentialsKinds(let groups):
///         showCredentialsKindPicker(for: groups)
///     case .provider(let provider):
///         showAddCredentials(for: provider)
///     }
/// }
/// ```
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
            case .credentialsKinds(let kinds):
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
    public struct CredentialsKindNode: Comparable {
        public static func < (lhs: ProviderTree.CredentialsKindNode, rhs: ProviderTree.CredentialsKindNode) -> Bool {
            return lhs.credentialsKind.sortOrder < rhs.credentialsKind.sortOrder
        }

        public static func == (lhs: ProviderTree.CredentialsKindNode, rhs: ProviderTree.CredentialsKindNode) -> Bool {
            return lhs.provider.id == rhs.provider.id
        }

        /// A unique identifier of a `CredentialsKindNode`.
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

        public var credentialsKind: Credentials.Kind { provider.credentialsKind }

        public var displayDescription: String { provider.displayDescription.isEmpty ? provider.credentialsKind.description : provider.displayDescription }

        public var imageURL: URL? { provider.image }
    }

    /// A parent node of the tree structure, with a list of either `CredentialsKindNode` children or a single `Provider`.
    public enum AccessTypeNode: Comparable {
        public static func < (lhs: ProviderTree.AccessTypeNode, rhs: ProviderTree.AccessTypeNode) -> Bool {
            return lhs.accessType < rhs.accessType
        }

        public static func == (lhs: ProviderTree.AccessTypeNode, rhs: ProviderTree.AccessTypeNode) -> Bool {
            switch (lhs, rhs) {
            case (.provider(let l), .provider(let r)):
                return l.id == r.id
            case (.credentialsKinds(let l), .credentialsKinds(let r)):
                return l == r
            default:
                return false
            }
        }

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
        case credentialsKinds([CredentialsKindNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByCredentialsKind = providers
                    .map(CredentialsKindNode.init(provider:))
                    .sorted()
                self = .credentialsKinds(providersGroupedByCredentialsKind)
            }
        }

        public var id: ID { ID(significantProvider.id.value) }

        public var providers: [Provider] {
            switch self {
            case .credentialsKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        fileprivate var firstProvider: Provider {
            switch self {
            case .credentialsKinds(let nodes):
                return nodes[0].provider
            case .provider(let provider):
                return provider
            }
        }

        fileprivate var significantProvider: Provider {
            switch self {
            case .credentialsKinds(let nodes):
                return (nodes.first { $0.imageURL != nil })?.provider ?? firstProvider
            case .provider(let provider):
                return provider
            }
        }

        public var accessType: Provider.AccessType { firstProvider.accessType }

        public var imageURL: URL? { significantProvider.image }
    }

    /// A parent node of the tree structure, with a list of either `AccessTypeNode`, `CredentialsKindNode` children or a single `Provider`.
    public enum FinancialInstitutionNode: Comparable {
        public static func < (lhs: ProviderTree.FinancialInstitutionNode, rhs: ProviderTree.FinancialInstitutionNode) -> Bool {
            return lhs.financialInstitution.name < rhs.financialInstitution.name
        }

        public static func == (lhs: ProviderTree.FinancialInstitutionNode, rhs: ProviderTree.FinancialInstitutionNode) -> Bool {
            switch (lhs, rhs) {
            case (.accessTypes(let l), .accessTypes(let r)):
                return l == r
            case (.credentialsKinds(let l), .credentialsKinds(let r)):
                return l == r
            case (.provider(let l), .provider(let r)):
                return l.id == r.id
            default:
                return false
            }
        }

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
        case credentialsKinds([CredentialsKindNode])
        case accessTypes([AccessTypeNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                    let providersGroupedByCredentialsKind = providers
                        .map(CredentialsKindNode.init(provider:))
                        .sorted()
                    self = .credentialsKinds(providersGroupedByCredentialsKind)
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values
                        .map(AccessTypeNode.init(providers:))
                        .sorted()
                    self = .accessTypes(providersGroupedByAccessType)
                }
            }
        }

        public var id: ID { ID(significantProvider.id.value) }

        public var providers: [Provider] {
            switch self {
            case .accessTypes(let nodes):
                return nodes.flatMap { $0.providers }
            case .credentialsKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        fileprivate var firstProvider: Provider {
            switch self {
            case .accessTypes(let accessTypeGroups):
                return accessTypeGroups[0].firstProvider
            case .credentialsKinds(let groups):
                return groups[0].provider
            case .provider(let provider):
                return provider
            }
        }

        fileprivate var significantProvider: Provider {
            switch self {
            case .accessTypes(let accessTypeGroups):
                return (accessTypeGroups.first { $0.imageURL != nil})?.significantProvider ?? firstProvider
            case .credentialsKinds(let groups):
                return (groups.first { $0.imageURL != nil })?.provider ?? firstProvider
            case .provider(let provider):
                return provider
            }
        }

        public var financialInstitution: Provider.FinancialInstitution { firstProvider.financialInstitution }

        public var imageURL: URL? { significantProvider.image }
    }

    /// A parent node of the tree structure, with a list of either `FinancialInstitutionNode`, `AccessTypeNode`, `CredentialsKindNode` children or a single `Provider`.
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
        case credentialsKinds([CredentialsKindNode])
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
                        let providersGroupedByCredentialsKind = providers
                            .map(CredentialsKindNode.init(provider:))
                            .sorted()
                        self = .credentialsKinds(providersGroupedByCredentialsKind)
                    } else {
                        let providersGroupedByAccessType = providersGroupedByAccessTypes.values
                            .map(AccessTypeNode.init(providers:))
                            .sorted()
                        self = .accessTypes(providersGroupedByAccessType)
                    }
                } else {
                    let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitution.values
                        .map(FinancialInstitutionNode.init(providers:))
                        .sorted()
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
            case .credentialsKinds(let nodes):
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
            case .credentialsKinds(let nodes):
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
            case .credentialsKinds(let groups):
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
            case .credentialsKinds(let kinds):
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
