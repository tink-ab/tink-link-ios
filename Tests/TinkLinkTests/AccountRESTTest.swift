import Foundation
@testable import TinkLink
import XCTest

class AccountRESTTest: XCTestCase {
    func testAccountMapping() {
        let restTransferDestination = RESTTransferDestination(
            balance: 0.0,
            displayBankName: nil,
            displayAccountNumber: "FR30 2004 1010 0500 0263 0303 700",
            uri: "iban://FR3020041010050002630303700?name=Checking+Account+tink+zero+balance",
            name: "Checking Account tink zero balance",
            type: .checking,
            matchesMultiple: false
        )
        let restCurrencyDenominatedAmount = RESTCurrencyDenominatedAmount(
            unscaledValue: 6861,
            scale: 2,
            currencyCode: "EUR"
        )

        let restAccount = RESTAccount(
            accountNumber: "FR1420041010050015664355590",
            balance: 68.61,
            credentialsId: "8a9255f210874f3eb5aefd78d412f6fa",
            excluded: false,
            favored: true,
            id: "f7c4038dfb6f46109ecba4a6f079a418",
            name: "Checking Account tink 1",
            ownership: 1.0,
            type: .checking,
            identifiers: "[\"iban://FR1420041010050015664355590?name=testAccount\"]",
            transferDestinations: [restTransferDestination],
            details: nil,
            holderName: nil,
            closed: false,
            flags: "[]",
            accountExclusion: ._none,
            currencyDenominatedBalance: restCurrencyDenominatedAmount,
            refreshed: Date(),
            financialInstitutionId: "f58e31ebaf625c15a9601aa4deac83d0"
        )

        let account = Account(restAccount: restAccount)
        XCTAssertEqual(account.credentialsID.value, restAccount.credentialsId)
        XCTAssertEqual(account.id.value, restAccount.id)
        XCTAssertEqual(account.financialInstitutionID?.value, restAccount.financialInstitutionId)
        XCTAssertEqual(account.name, restAccount.name)
        XCTAssertEqual(account.accountNumber, restAccount.accountNumber)
        XCTAssertEqual(account.name, restAccount.name)
        XCTAssertEqual(account.kind, Account.Kind(restAccountType: restAccount.type))
        XCTAssertNil(account.details)
    }
}
