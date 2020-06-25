/// Represents a set of data types that you can aggregate from a provider.
public struct RefreshableItems: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Checking accounts data types to aggregate.
    public static let checkingAccounts = RefreshableItems(rawValue: 1 << 0)
    /// Checking transactions data types to aggregate.
    public static let checkingTransactions = RefreshableItems(rawValue: 1 << 1)
    /// Saving accounts data types to aggregate.
    public static let savingAccounts = RefreshableItems(rawValue: 1 << 2)
    /// Saving transactions data types to aggregate.
    public static let savingTransactions = RefreshableItems(rawValue: 1 << 3)
    /// Credit Card accounts data types to aggregate.
    public static let creditCardAccounts = RefreshableItems(rawValue: 1 << 4)
    /// Credit Card transactions data types to aggregate.
    public static let creditCardTransactions = RefreshableItems(rawValue: 1 << 5)
    /// Loan accounts data types to aggregate.
    public static let loanAccounts = RefreshableItems(rawValue: 1 << 6)
    /// Loan transactions data types to aggregate.
    public static let loanTransactions = RefreshableItems(rawValue: 1 << 7)
    /// Investment accounts data types to aggregate.
    public static let investmentAccounts = RefreshableItems(rawValue: 1 << 8)
    /// Investment transactions data types to aggregate.
    public static let investmentTransactions = RefreshableItems(rawValue: 1 << 9)
    /// EInvoices data types to aggregate.
    public static let eInvoices = RefreshableItems(rawValue: 1 << 10)
    /// Transfer data types to aggregate.
    public static let transferDestinations = RefreshableItems(rawValue: 1 << 11)
    /// Identity data types to aggregate.
    public static let identityData = RefreshableItems(rawValue: 1 << 12)

    /// All kinds of account data.
    ///
    /// Contains .checkingAccounts`, `.savingAccounts`, `.creditCardAccounts`, `.loanAccounts`, and `.investmentAccounts`.
    public static let accounts: RefreshableItems = [.checkingAccounts, .savingAccounts, .creditCardAccounts, .loanAccounts, .investmentAccounts]
    /// All kinds of all transaction data.
    ///
    /// Contains .checkingTransactions`, `.savingTransactions`, `.creditCardTransactions`, `.loanTransactions`, and `.investmentTransactions`.
    public static let transactions: RefreshableItems = [.checkingTransactions, .savingTransactions, .creditCardTransactions, .loanTransactions, .investmentTransactions]
    /// All possible data.
    ///
    /// Contains all types of refreshable items.
    public static let all: RefreshableItems = [.accounts, .transactions, .eInvoices, .transferDestinations, .identityData]

    var strings: [String] {
        var strings: [String] = []

        if contains(.checkingAccounts) {
            strings.append("CHECKING_ACCOUNTS")
        }
        if contains(.checkingTransactions) {
            strings.append("CHECKING_TRANSACTIONS")
        }
        if contains(.savingAccounts) {
            strings.append("SAVING_ACCOUNTS")
        }
        if contains(.savingTransactions) {
            strings.append("SAVING_TRANSACTIONS")
        }
        if contains(.creditCardAccounts) {
            strings.append("CREDITCARD_ACCOUNTS")
        }
        if contains(.creditCardTransactions) {
            strings.append("CREDITCARD_TRANSACTIONS")
        }
        if contains(.loanAccounts) {
            strings.append("LOAN_ACCOUNTS")
        }
        if contains(.loanTransactions) {
            strings.append("LOAN_TRANSACTIONS")
        }
        if contains(.investmentAccounts) {
            strings.append("INVESTMENT_ACCOUNTS")
        }
        if contains(.investmentTransactions) {
            strings.append("INVESTMENT_TRANSACTIONS")
        }
        if contains(.eInvoices) {
            strings.append("EINVOICES")
        }
        if contains(.transferDestinations) {
            strings.append("TRANSFER_DESTINATIONS")
        }
        if contains(.identityData) {
            strings.append("IDENTITY_DATA")
        }
        return strings
    }
}

public extension RefreshableItems {
    /// Creates a set of refreshable items that corresponds to the providers capabilities.
    init(providerCapabilities: Provider.Capabilities) {
        var refreshableItems: RefreshableItems = []
        if providerCapabilities.contains(.checkingAccounts) {
            refreshableItems.insert([.checkingAccounts, .checkingTransactions])
        }
        if providerCapabilities.contains(.savingsAccounts) {
            refreshableItems.insert([.savingAccounts, .savingTransactions])
        }
        if providerCapabilities.contains(.creditCards) {
            refreshableItems.insert([.creditCardAccounts, .creditCardTransactions])
        }
        if providerCapabilities.contains(.loans) {
            refreshableItems.insert([.loanAccounts, .loanTransactions])
        }
        if providerCapabilities.contains(.investments) {
            refreshableItems.insert([.investmentAccounts, .investmentTransactions])
        }
        if providerCapabilities.contains(.eInvoices) {
            refreshableItems.insert(.eInvoices)
        }
        if providerCapabilities.contains(.transfers) {
            refreshableItems.insert(.transferDestinations)
        }
        if providerCapabilities.contains(.identityData) {
            refreshableItems.insert(.identityData)
        }
        self = refreshableItems
    }

    /// Returns a new set of refreshable items that contain the items in the set that the given provider capabilities supports.
    /// - Parameter providerCapabilities: A set of provider capabilities.
    /// - Returns: The subset of the items that the provider capabilities support.
    func supporting(providerCapabilities: Provider.Capabilities) -> RefreshableItems {
        return intersection(RefreshableItems(providerCapabilities: providerCapabilities))
    }
}
