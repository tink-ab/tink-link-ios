import Foundation
import TinkCore

extension Account {
    static let checkingTestAccount = Account(
        id: ID("f7c4038dfb6f46109ecba4a6f079a418"),
        credentialsID: Credentials.ID("8a9255f210874f3eb5aefd78d412f6fa"),
        name: "Checking Account tink 1",
        accountNumber: "FR1420041010050015664355590",
        kind: .checking,
        transferSourceIdentifiers: [URL(string: "iban://FR1420041010050015664355590?name=testAccount")!],
        holderName: nil,
        isClosed: false,
        currencyDenominatedBalance: CurrencyDenominatedAmount(Decimal(68.61), currencyCode: CurrencyCode("EUR")),
        refreshed: Date(),
        financialInstitutionID: Provider.FinancialInstitution.ID("f58e31ebaf625c15a9601aa4deac83d0")
    )

    static func makeTestAccount(
        credentials: Credentials
    ) -> Account {
        return Account(
            id: Account.ID(UUID().uuidString),
            credentialsID: credentials.id,
            name: "Checking Account tink 1",
            accountNumber: "FR1420041010050015664355590",
            kind: .checking,
            transferSourceIdentifiers: [URL(string: "iban://FR1420041010050015664355590?name=testAccount")!],
            holderName: nil,
            isClosed: false,
            currencyDenominatedBalance: CurrencyDenominatedAmount(Decimal(68.61), currencyCode: CurrencyCode("EUR")),
            refreshed: Date(),
            financialInstitutionID: Provider.FinancialInstitution.ID(UUID().uuidString)
        )
    }
}
