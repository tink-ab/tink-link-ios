import Foundation

/// The provider model represents financial institutions to where Tink can connect. It specifies how Tink accesses the financial institution, metadata about the financialinstitution, and what financial information that can be accessed.
public struct Provider: Identifiable {
    /// A unique identifier of a `Provider`.
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

        public let value: String
    }

    /// The unique identifier of the provider.
    /// - Note: This is used when creating new credentials.
    public let id: ID

    /// The display name of the provider.
    public let displayName: String

    /// Indicates what kind of financial institution the provider represents.
    public enum Kind {
        /// The kind of the provider is unknown.
        case unknown
        /// The provider is a bank.
        case bank
        /// The provider is a credit card.
        case creditCard
        /// The provider is a broker.
        case broker
        case other

        /// Indicates a test provider.
        case test
        case fraud

        case businessBank
        case firstParty

        public static var defaultKinds: Set<Provider.Kind> = [.bank, .creditCard, .broker, .other]
        /// A set of all providers kinds except for the test providers.
        public static var excludingTest: Set<Provider.Kind> = [.unknown, .bank, .creditCard, .broker, .other, .fraud]
        /// A set of all providers kinds. Note that this also includes test providers.
        public static var all: Set<Provider.Kind> = [.unknown, .bank, .creditCard, .broker, .other, .test, .fraud]
    }

    /// Indicates what kind of financial institution the provider represents.
    public let kind: Provider.Kind

    /// Indicates the current status of a provider.
    public enum Status {
        /// The status of the provider is unknown.
        case unknown
        /// The provider is enabled.
        case enabled
        /// The provider is disabled.
        case disabled
        /// The provider is temporarily disabled.
        case temporaryDisabled
        /// The provider is obsolute.
        case obsolete
    }

    /// Indicates the current status of the provider.
    /// - Note: It is only possible to perform credentials create or refresh actions on providers which are enabled.
    public let status: Status

    /// When creating a new credentials connected to the provider this will be the credential's kind.
    public let credentialsKind: Credentials.Kind

    /// Short description of how to authenticate when creating a new credentials for connected to the provider.
    public let helpText: String

    /// Indicates if the provider is popular. This is normally set to true for the biggest financial institutions on a market.
    public let isPopular: Bool

    internal struct FieldSpecification {
        // description
        internal let fieldDescription: String
        /// Gray text in the input view (Similar to a placeholder)
        internal let hint: String
        internal let maxLength: Int?
        internal let minLength: Int?
        /// Controls whether or not the field should be shown masked, like a password field.
        internal let isMasked: Bool
        internal let isNumeric: Bool
        internal let isImmutable: Bool
        internal let isOptional: Bool
        internal let name: String
        internal let initialValue: String
        internal let pattern: String
        internal let patternError: String
        /// Text displayed next to the input field
        internal let helpText: String
    }

    internal let fields: [FieldSpecification]

    /// A display name for providers which are branches of a bigger group.
    public let groupDisplayName: String

    /// A `URL` to an image representing the provider.
    public let image: URL?

    /// Short displayable description of the authentication type used.
    public let displayDescription: String

    /// Indicates what a provider is capable of.
    public struct Capabilities: OptionSet, Hashable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// The provider can perform transfers.
        public static let transfers = Capabilities(rawValue: 1 << 1)
        /// The provider has mortgage aggregation.
        public static let mortgageAggregation = Capabilities(rawValue: 1 << 2)
        /// The provider can aggregate checkings accounts.
        public static let checkingAccounts = Capabilities(rawValue: 1 << 3)
        /// The provider can aggregate savings accounts.
        public static let savingsAccounts = Capabilities(rawValue: 1 << 4)
        /// The provider can aggregate credit cards.
        public static let creditCards = Capabilities(rawValue: 1 << 5)
        /// The provider can aggregate investments.
        public static let investments = Capabilities(rawValue: 1 << 6)
        /// The provider can aggregate loans.
        public static let loans = Capabilities(rawValue: 1 << 7)
        /// The provider can perform payments.
        public static let payments = Capabilities(rawValue: 1 << 8)
        /// The provider can aggregate mortgage loans.
        public static let mortgageLoan = Capabilities(rawValue: 1 << 9)
        /// The provider can fetch identity data.
        public static let identityData = Capabilities(rawValue: 1 << 10)
        /// The provider can fetch e-invoice data.
        public static let eInvoices = Capabilities(rawValue: 1 << 10)
        /// A list representing all possible capabilities.
        public static let all: Capabilities = [.transfers, .mortgageAggregation, .checkingAccounts, .savingsAccounts, .creditCards, .investments, .loans, .payments, .mortgageLoan, .identityData]
    }

    /// Indicates what this provider is capable of, in terms of financial data it can aggregate and if it can execute payments.
    public let capabilities: Capabilities

    /// What Tink uses to access data.
    public enum AccessType: CustomStringConvertible, Hashable, Comparable {
        public static func < (lhs: AccessType, rhs: AccessType) -> Bool {
            switch (lhs, rhs) {
            case (.openBanking, _):
                return true
            case (_, .unknown):
                return true
            default:
                return false
            }
        }

        case unknown
        case openBanking
        case other

        public var description: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .openBanking:
                return "Open Banking"
            case .other:
                return "Other"
            }
        }

        /// A set of all access types.
        public static let all: Set<AccessType> = [.openBanking, .other, .unknown]
    }

    /// What Tink uses to access the data.
    public let accessType: AccessType

    /// The market of the provider.
    /// - Note: Each provider is unique per market.
    public let marketCode: String

    /// The financial institution.
    public let financialInstitution: FinancialInstitution
}

public extension Set where Element == Provider.Kind {
    /// A set of all providers kinds. Note that this also includes test providers.
    static var all: Set<Provider.Kind> { Provider.Kind.all }
    /// A set of all providers kinds except for the test providers.
    static var excludingTest: Set<Provider.Kind> { Provider.Kind.excludingTest }
    /// A set of default provider kinds
    static var defaultKinds: Set<Provider.Kind> = [.bank, .creditCard, .broker, .other]
}

public extension Set where Element == Provider.AccessType {
    /// A set of all access types.
    static var all: Set<Provider.AccessType> { Provider.AccessType.all }
}
