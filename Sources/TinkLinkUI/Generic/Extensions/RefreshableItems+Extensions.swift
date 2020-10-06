import TinkLink

extension RefreshableItems {
    static func makeRefreshableItems(scopes: [Scope], provider: Provider) -> RefreshableItems {
        var requestedRefreshableItems: RefreshableItems = [.accounts, .eInvoices, .transferDestinations]

        // Based on: https://github.com/tink-ab/tink-backend/blob/39c97c74a0eba4d039b5347de3781df378c3692f/src/main-system-features/aggregation_controller_v1/src/main/java/se/tink/libraries/aggregation_controller_v1/enums/RefreshableItem.java#L36
        if scopes.contains(.transactions(.read)) || scopes.contains(.transactions(.read, .write)) || scopes.contains(.transactions(.read, .write, .categorize)) || scopes.contains(.transactions(.read, .categorize)) {
            requestedRefreshableItems.formUnion(.transactions)
        }

        if scopes.contains(.identity(.read)) || scopes.contains(.identity(.read, .write)) {
            requestedRefreshableItems.insert(.identityData)
        }

        // This makes sure that at least one of the provider capability that maps to
        // that refreshable item is supported by the provider, otherwise an error would be
        // raised because of provider capability validation on the backend
        return requestedRefreshableItems.supporting(providerCapabilities: provider.capabilities)
    }
}
