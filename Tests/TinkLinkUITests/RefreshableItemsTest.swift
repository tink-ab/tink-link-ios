import XCTest
import TinkCore
@testable import TinkLinkUI

class RefreshableItemsTest: XCTestCase {
    let testProvider = Provider(
        capabilities: [.all]
    )

    func testTransactionsScopeRefreshableItems() {
        let targetRefreshItems: RefreshableItems = [.accounts, .transferDestinations, .transactions]

        let readTransactionsScopes: [Scope] = [
            .transactions(.read)
        ]
        let readTransactionsRefreshItems = RefreshableItems.makeRefreshableItems(scopes: readTransactionsScopes, provider: testProvider)

        let nestedReadWriteTransactionsScopes: [Scope] = [
            .transactions(.read, .write)
        ]
        let nestedReadWriteTransactionsRefreshItems = RefreshableItems.makeRefreshableItems(scopes: nestedReadWriteTransactionsScopes, provider: testProvider)

        let nestedReadCategorizeTransactionsScopes: [Scope] = [
            .transactions(.read, .categorize)
        ]
        let nestedReadCategorizeTransactionsRefreshItems = RefreshableItems.makeRefreshableItems(scopes: nestedReadCategorizeTransactionsScopes, provider: testProvider)

        let nestedReadWriteCategorizeTransactionsScopes: [Scope] = [
            .transactions(.read, .write, .categorize)
        ]
        let nestedReadWriteCategorizeTransactionsRefreshItems = RefreshableItems.makeRefreshableItems(scopes: nestedReadWriteCategorizeTransactionsScopes, provider: testProvider)

        XCTAssertEqual(targetRefreshItems, readTransactionsRefreshItems)
        XCTAssertEqual(targetRefreshItems, nestedReadWriteTransactionsRefreshItems)
        XCTAssertEqual(targetRefreshItems, nestedReadCategorizeTransactionsRefreshItems)
        XCTAssertEqual(targetRefreshItems, nestedReadWriteCategorizeTransactionsRefreshItems)
    }

    func testIdentityScopeRefreshableItems() {
        let targetRefreshItems: RefreshableItems = [.accounts, .transferDestinations, .identityData]

        let readIdentityScopes: [Scope] = [
            .identity(.read)
        ]
        let readIdentityRefreshItems = RefreshableItems.makeRefreshableItems(scopes: readIdentityScopes, provider: testProvider)

        let nestedReadWriteIdentityScopes: [Scope] = [
            .identity(.read, .write)
        ]
        let nestedReadWriteIdentityRefreshItems = RefreshableItems.makeRefreshableItems(scopes: nestedReadWriteIdentityScopes, provider: testProvider)

        XCTAssertEqual(targetRefreshItems, readIdentityRefreshItems)
        XCTAssertEqual(targetRefreshItems, nestedReadWriteIdentityRefreshItems)
    }
}
