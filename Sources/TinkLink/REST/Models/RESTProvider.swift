import Foundation

struct RESTProviders: Decodable {
    let providers: [RESTProvider]
}

/// The provider model represents financial institutions to where Tink can connect. It specifies how Tink accesses
/// the financial institution, metadata about the financialinstitution, and what financial information that can be accessed.
struct RESTProvider: Decodable {
    enum AccessType: String, DefaultableDecodable {
        case openBanking = "OPEN_BANKING"
        case other = "OTHER"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTProvider.AccessType = .unknown
    }

    enum AuthenticationFlow: String, DefaultableDecodable {
        case embedded = "EMBEDDED"
        case redirect = "REDIRECT"
        case decoupled = "DECOUPLED"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTProvider.AuthenticationFlow = .unknown
    }

    enum Capabilities: String, DefaultableDecodable {
        case unknown = "UNKNOWN"
        case transfers = "TRANSFERS"
        case einvoices = "EINVOICES"
        case mortgageAggregation = "MORTGAGE_AGGREGATION"
        case checkingAccounts = "CHECKING_ACCOUNTS"
        case savingsAccounts = "SAVINGS_ACCOUNTS"
        case creditCards = "CREDIT_CARDS"
        case loans = "LOANS"
        case investments = "INVESTMENTS"
        case payments = "PAYMENTS"
        case identityData = "IDENTITY_DATA"
        case createBeneficiaries = "CREATE_BENEFICIARIES"
        case listBeneficiaries = "LIST_BENEFICIARIES"

        static var decodeFallbackValue: RESTProvider.Capabilities = .unknown
    }

    enum CredentialsType: String, DefaultableDecodable {
        case password = "PASSWORD"
        case mobileBankid = "MOBILE_BANKID"
        case keyfob = "KEYFOB"
        case thirdPartyApp = "THIRD_PARTY_APP"
        case fraud = "FRAUD"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTProvider.CredentialsType = .unknown
    }

    enum Status: String, DefaultableDecodable {
        case enabled = "ENABLED"
        case temporaryDisabled = "TEMPORARY_DISABLED"
        case disabled = "DISABLED"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTProvider.Status = .unknown
    }

    enum ModelType: String, DefaultableDecodable {
        case bank = "BANK"
        case creditCard = "CREDIT_CARD"
        case broker = "BROKER"
        case test = "TEST"
        case fraud = "FRAUD"
        case other = "OTHER"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTProvider.ModelType = .unknown
    }

    /// What Tink uses to access the data.
    var accessType: AccessType
    /// (PSD2 change - Not yet implemented) - What type of authentication flow used to access the data.
//    var authenticationFlow: AuthenticationFlow
    /// Indicates what this provider is capable of, in terms of financial data it can aggregate and if it can execute payments.
    var capabilities: [Capabilities]
    /// When creating a new credential connected to the provider this will be the credentials type.
    var credentialsType: CredentialsType
    /// The default currency of the provider.
    var currency: String
    /// The display name of the provider.
    var displayName: String
    /// Short displayable description of the authentication type used.
    var displayDescription: String?
    /// List of fields which need to be provided when creating a credential connected to the provider.
    var fields: [RESTField]
    /// A unique identifier to group providers belonging the same financial institution.
    var financialInstitutionId: String
    /// The name of the financial institution.
    var financialInstitutionName: String
    /// A display name for providers which are branches of a bigger group.
    var groupDisplayName: String?
    var images: RESTImageUrls?
    /// The market of the provider. Each provider is unique per market.
    var market: String
    /// Indicates if the provider requires multi-factor authentication.
    var multiFactor: Bool
    /// The unique identifier of the provider. This is used when creating new credentials.
    var name: String
    /// Short description of how to authenticate when creating a new credential for connected to the provider.
    var passwordHelpText: String?
    /// Indicates if the provider is popular. This is normally set to true for the biggest financial institutions on a market.
    var popular: Bool
    /// Indicates the current status of the provider. It is only possible to perform credentials create or refresh actions on providers which are enabled.
    var status: Status
    /// Indicates if Tink can aggregate transactions for this provider.
    var transactional: Bool
    /// Indicates what type of financial institution the provider represents.
    var type: ModelType
}
