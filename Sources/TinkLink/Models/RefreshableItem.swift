public enum RefreshableItem: String, CaseIterable {
    case checkingAccounts = "CHECKING_ACCOUNTS"
    case checkingTransactions = "CHECKING_TRANSACTIONS"
    case savingAccounts = "SAVING_ACCOUNTS"
    case savingTransactions = "SAVING_TRANSACTIONS"
    case creditCardAccounts = "CREDITCARD_ACCOUNTS"
    case creditCardTransactions = "CREDITCARD_TRANSACTIONS"
    case loanAccounts = "LOAN_ACCOUNTS"
    case loanTransactions = "LOAN_TRANSACTIONS"
    case investmentAccounts = "INVESTMENT_ACCOUNTS"
    case investmentTransactions = "INVESTMENT_TRANSACTIONS"
    case eInvoices = "EINVOICES"
    case transferDestinations = "TRANSFER_DESTINATIONS"
    case identityData = "IDENTITY_DATA"
}

extension RefreshableItem {
    static func makeFromScopes(_ scopes: [Scope], provider: Provider) -> Set<RefreshableItem> {

        let providerCapabilities = provider.capabilities

        var requestedRefreshableItems: Set<RefreshableItem> = [
            .checkingAccounts,
            .savingAccounts,
            .creditCardAccounts,
            .loanAccounts,
            .investmentAccounts,
            .eInvoices,
            .transferDestinations]

        // Based on: https://github.com/tink-ab/tink-backend/blob/39c97c74a0eba4d039b5347de3781df378c3692f/src/main-system-features/aggregation_controller_v1/src/main/java/se/tink/libraries/aggregation_controller_v1/enums/RefreshableItem.java#L36
        if scopes.scopeDescription.contains("transactions:read") {
            requestedRefreshableItems.formUnion([
                .checkingTransactions,
                .savingTransactions,
                .creditCardTransactions,
                .loanTransactions,
                .investmentTransactions])
        }

        if scopes.scopeDescription.contains("identity:read") {
            requestedRefreshableItems.insert(.identityData)
        }

        return requestedRefreshableItems.filter { (item) -> Bool in
            let capabilities = makeProviderCapabilities(refreshableItem: item)
            return providerCapabilities.contains(capabilities)
        }
    }

    static private func makeProviderCapabilities(refreshableItem: RefreshableItem) -> Provider.Capabilities {
        switch refreshableItem {
        case .checkingAccounts, .checkingTransactions: return .checkingAccounts
        case .savingAccounts, .savingTransactions: return .savingsAccounts
        case .creditCardAccounts, .creditCardTransactions: return .creditCards
        case .loanAccounts, .loanTransactions: return .loans
        case .investmentAccounts, .investmentTransactions: return .investments
        case .eInvoices: return .eInvoices
        case .transferDestinations: return .transfers
        case .identityData: return .identityData
        }
    }
}
