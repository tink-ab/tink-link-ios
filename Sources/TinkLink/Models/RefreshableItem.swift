public struct RefreshableItems: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let checkingAccounts = RefreshableItems(rawValue: 1 << 0)
    public static let checkingTransactions = RefreshableItems(rawValue: 1 << 1)
    public static let savingAccounts = RefreshableItems(rawValue: 1 << 2)
    public static let savingTransactions = RefreshableItems(rawValue: 1 << 3)
    public static let creditCardAccounts = RefreshableItems(rawValue: 1 << 4)
    public static let creditCardTransactions = RefreshableItems(rawValue: 1 << 5)
    public static let loanAccounts = RefreshableItems(rawValue: 1 << 6)
    public static let loanTransactions = RefreshableItems(rawValue: 1 << 7)
    public static let investmentAccounts = RefreshableItems(rawValue: 1 << 8)
    public static let investmentTransactions = RefreshableItems(rawValue: 1 << 9)
    public static let eInvoices = RefreshableItems(rawValue: 1 << 10)
    public static let transferDestinations = RefreshableItems(rawValue: 1 << 11)
    public static let identityData = RefreshableItems(rawValue: 1 << 12)

    public static let accounts: RefreshableItems = [.checkingAccounts, .savingAccounts, .creditCardAccounts, .loanAccounts, .investmentAccounts]
    public static let transactions: RefreshableItems = [.checkingTransactions, .savingTransactions, .creditCardTransactions, .loanTransactions, .investmentTransactions]

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

extension RefreshableItems {
    static func makeFromScopes(_ scopes: [Scope], provider: Provider) -> RefreshableItems {

        let providerCapabilities = provider.capabilities

        var requestedRefreshableItems: RefreshableItems = [.accounts, .eInvoices, .transferDestinations]

        // Based on: https://github.com/tink-ab/tink-backend/blob/39c97c74a0eba4d039b5347de3781df378c3692f/src/main-system-features/aggregation_controller_v1/src/main/java/se/tink/libraries/aggregation_controller_v1/enums/RefreshableItem.java#L36
        if scopes.scopeDescription.contains("transactions:read") {
            requestedRefreshableItems.formUnion(.transactions)
        }

        if scopes.scopeDescription.contains("identity:read") {
            requestedRefreshableItems.insert(.identityData)
        }

        // This makes sure that at least one of the provider capability that maps to
        // that refreshable item is supported by the provider, otherwise an error would be
        // raised because of provider capability validation on the backend
        return requestedRefreshableItems.intersection(makeRefreshableItems(providerCapabilities: providerCapabilities))
    }

    static private func makeRefreshableItems(providerCapabilities: Provider.Capabilities) -> RefreshableItems {
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
        return refreshableItems
    }
}
