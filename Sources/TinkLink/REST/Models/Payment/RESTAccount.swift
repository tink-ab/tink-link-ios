import Foundation

/// An account could either be a debit account, a credit card, a loan or mortgage.
struct RESTAccount: Decodable {
    enum ModelType: String, DefaultableDecodable {
        case checking = "CHECKING"
        case savings = "SAVINGS"
        case investment = "INVESTMENT"
        case mortgage = "MORTGAGE"
        case creditCard = "CREDIT_CARD"
        case loan = "LOAN"
        case pension = "PENSION"
        case other = "OTHER"
        case external = "EXTERNAL"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTAccount.ModelType = .unknown
    }

    enum Flag: String, DefaultableDecodable {
        case business = "BUSINESS"
        case mandate = "MANDATE"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTAccount.Flag = .unknown
    }

    enum AccountExclusion: String, DefaultableDecodable {
        case aggregation = "AGGREGATION"
        case pfmAndSearch = "PFM_AND_SEARCH"
        case pfmData = "PFM_DATA"
        case _none = "NONE"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTAccount.AccountExclusion = .unknown
    }

    /// The account number of the account. The format of the account numbers may differ between account types and banks. This property can be updated in a update account request.
    var accountNumber: String

    /// The current balance of the account.
    /// The definition of the balance property differs between account types.
    /// `SAVINGS`: the balance represent the actual amount of cash in the account.
    /// `INVESTMENT`: the balance represents the value of the investments connected to this accounts including any available cash.
    /// `MORTGAGE`: the balance represents the loan debt outstanding from this account.
    /// `CREDIT_CARD`: the balance represent the outstanding balance on the account, it does not include any available credit or purchasing power the user has with the credit provider.
    var balance: Double

    /// The internal identifier of the credentials that the account belongs to.
    var credentialsId: String

    /// Indicates if the user has excluded the account. Categorization and PFM Features are excluded, and transactions belonging to this account are not searchable. This property can be updated in a update account request.
    var excluded: Bool

    /// Indicates if the user has favored the account. This property can be updated in a update account request.
    var favored: Bool

    /// The internal identifier of account.
    var id: String

    /// The display name of the account. This property can be updated in a update account request.
    var name: String

    /// The ownership ratio indicating how much of the account is owned by the user. The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated. This property has a default value, and it can only be updated by you in a update account request.
    var ownership: Double

    /// The type of the account. This property can be updated in a update account request.
    var type: ModelType

    /// All possible ways to uniquely identify this `Account`; An se-identifier is built up like: se://{clearingnumber}{accountnumber};
    var identifiers: String?

    /// The destinations this Account can transfer money to, be that payment or bank transfer recipients. This field is only populated if account data is requested via GET /transfer/accounts.
    var transferDestinations: [RESTTransferDestination]?

    /// Details contains information only applicable for accounts of the types loans and mortgages.
    /// All banks do not offer detail information about their loan and mortgages therefore will details not be present on all accounts of the types loan and mortgages.
    var details: RESTAccountDetails?

    /// The name of the account holder
    var holderName: String?

    /// A closed account indicates that it was no longer available from the connected financial institution, most likely due to it having been closed by the user.
    var closed: Bool?

    /// A list of flags specifying attributes on an account.
    var flags: String?

    /// Indicates features this account should be excluded from.
    /// Possible values are:
    /// `NONE`: No features are excluded from this account.
    /// `PFM_DATA`: Personal Finance Management Features, like statistics and activities are excluded.
    /// `PFM_AND_SEARCH`: Personal Finance Management Features are excluded, and transactions belonging to this account are not searchable. This is the equivalent of the, now deprecated, boolean flag `excluded`.
    /// `AGGREGATION`: No data will be aggregated for this account and, all data associated with the account is removed (except account name and account number).
    /// This property can be updated in a update account request.
    var accountExclusion: AccountExclusion

    /// The current balance of the account.
    /// The definition of the balance property differ between account types.
    /// `SAVINGS`: the balance represent the actual amount of cash in the account.
    /// `INVESTMENT`: the balance represents the value of the investments connected to this accounts including any available cash.
    /// `MORTGAGE`: the balance represents the loan debt outstanding from this account.
    /// `CREDIT_CARD`: the balance represent the outstanding balance on the account, it does not include any available credit or purchasing power the user has with the credit provider.
    /// The balance is represented as a scale and unscaled value together with the ISO 4217 currency code of the amount.
    var currencyDenominatedBalance: RESTCurrencyDenominatedAmount?

    /// Timestamp of when the account was last refreshed.
    var refreshed: Date?

    /// A unique identifier to group accounts belonging the same financial institution. Available for aggregated accounts only.
    var financialInstitutionId: String?
}
