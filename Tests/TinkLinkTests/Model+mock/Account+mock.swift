import Foundation
@testable import TinkLink

extension Account {
    static let checkingTestAccount = Account(
        accountNumber: "FR1420041010050015664355590",
        balance: 68.61,
        credentialsID: Credentials.ID("8a9255f210874f3eb5aefd78d412f6fa"),
        isFavored: true,
        id: ID("f7c4038dfb6f46109ecba4a6f079a418"),
        name: "Checking Account tink 1",
        ownership: 1.0,
        kind: .checking,
        transferSourceIdentifiers: [URL(string: "iban://FR1420041010050015664355590?name=testAccount")!],
        transferDestinations: nil,
        details: nil,
        holderName: nil,
        isClosed: false,
        flags: [],
        accountExclusion: nil,
        currencyDenominatedBalance: CurrencyDenominatedAmount(value: Decimal(68.61), currencyCode: CurrencyCode("EUR")),
        refreshed: Date(),
        financialInstitutionID: Provider.FinancialInstitution.ID("f58e31ebaf625c15a9601aa4deac83d0")
    )
}
