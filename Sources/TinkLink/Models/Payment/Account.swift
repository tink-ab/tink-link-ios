import Foundation

/// An account could either be a debit account, a credit card, a loan or mortgage.
public struct Account {
    /// The kind of the account.
    public enum Kind {
        /// A checking account.
        case checking
        /// A savings account.
        case savings
        /// An investment account.
        case investment
        /// A mortgage account.
        case mortgage
        /// A creditCard account.
        case creditCard
        /// A loan account.
        case loan
        /// A pension account.
        case pension
        /// Other type account.
        case other
        /// An external account.
        case external
        /// An unknown account.
        case unknown
    }

    enum Flag {
        case business
        case mandate
        case unknown
    }

    enum AccountExclusion {
        case aggregation
        case pfmAndSearch
        case pfmData
        case unknown
    }

    /// A unique identifier of an `Account`.
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        /// Creates an instance initialized to the given string value.
        /// - Parameter value: The value of the new instance.
        public init(_ value: String) {
            self.value = value
        }

        /// The string value of the ID.
        public let value: String
    }

    /// The account number of the account. The format of the account numbers may differ between account types and banks. This property can be updated in a update account request.
    public let accountNumber: String

    /// The current balance of the account.
    /// The definition of the balance property differs between account types.
    /// `SAVINGS`: the balance represent the actual amount of cash in the account.
    /// `INVESTMENT`: the balance represents the value of the investments connected to this accounts including any available cash.
    /// `MORTGAGE`: the balance represents the loan debt outstanding from this account.
    /// `CREDIT_CARD`: the balance represent the outstanding balance on the account, it does not include any available credit or purchasing power the user has with the credit provider.
    let balance: Double

    /// The internal identifier of the credentials that the account belongs to.
    public let credentialsID: Credentials.ID

    /// Indicates if the user has favored the account. This property can be updated in a update account request.
    let isFavored: Bool

    /// The internal identifier of account.
    public let id: Account.ID

    /// The display name of the account. This property can be updated in a update account request.
    public let name: String

    /// The ownership ratio indicating how much of the account is owned by the user. The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated. This property has a default value, and it can only be updated by you in a update account request.
    let ownership: Double

    /// The type of the account. This property can be updated in a update account request.
    public let kind: Kind

    /// All possible ways to uniquely identify this `Account`; An se-identifier is built up like: se://{clearingnumber}{accountnumber};
    let transferSourceIdentifiers: [URL]?

    /// The destinations this Account can transfer money to, be that payment or bank transfer recipients. This field is only populated if account data is requested via GET /transfer/accounts.
    let transferDestinations: [TransferDestination]?

    /// Details contains information only applicable for accounts of the types loans and mortgages.
    /// All banks do not offer detail information about their loan and mortgages therefore will details not be present on all accounts of the types loan and mortgages.
    let details: AccountDetails?

    /// The name of the account holder
    public let holderName: String?

    /// A closed account indicates that it was no longer available from the connected financial institution, most likely due to it having been closed by the user.
    public let isClosed: Bool?

    /// A list of flags specifying attributes on an account.
    let flags: [Flag]?

    /// Indicates features this account should be excluded from.
    /// Possible values are:
    /// If `nil`, then no features are excluded from this account.
    /// `PFM_DATA`: Personal Finance Management Features, like statistics and activities are excluded.
    /// `PFM_AND_SEARCH`: Personal Finance Management Features are excluded, and transactions belonging to this account are not searchable. This is the equivalent of the, now deprecated, boolean flag `excluded`.
    /// `AGGREGATION`: No data will be aggregated for this account and, all data associated with the account is removed (except account name and account number).
    /// This property can be updated in a update account request.
    let accountExclusion: AccountExclusion?

    /// The current balance of the account.
    /// The definition of the balance property differ between account types.
    /// `SAVINGS`: the balance represent the actual amount of cash in the account.
    /// `INVESTMENT`: the balance represents the value of the investments connected to this accounts including any available cash.
    /// `MORTGAGE`: the balance represents the loan debt outstanding from this account.
    /// `CREDIT_CARD`: the balance represent the outstanding balance on the account, it does not include any available credit or purchasing power the user has with the credit provider.
    /// The balance is represented as a scale and unscaled value together with the ISO 4217 currency code of the amount.
    public let currencyDenominatedBalance: CurrencyDenominatedAmount?

    /// Timestamp of when the account was last refreshed.
    public let refreshed: Date?

    /// A unique identifier to group accounts belonging the same financial institution. Available for aggregated accounts only.
    public let financialInstitutionID: Provider.FinancialInstitution.ID?
}
