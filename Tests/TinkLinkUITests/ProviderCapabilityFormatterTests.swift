import XCTest
import TinkCore
@testable import TinkLinkUI

extension Provider {
    init(capabilities: Capabilities) {
        self.init(
            id: ID("test-provider"),
            displayName: "Test",
            authenticationUserType: .personal,
            kind: .bank,
            status: .enabled,
            credentialsKind: .password,
            helpText: "",
            isPopular: false,
            fields: [],
            groupDisplayName: "Test",
            image: nil,
            displayDescription: "Password",
            capabilities: capabilities,
            accessType: .other,
            marketCode: "SE",
            financialInstitution: FinancialInstitution(
                id: FinancialInstitution.ID("f128639c-171b-46eb-8eff-219705bcbbcc"),
                name: "Test"
            )
        )
    }
}

class ProviderCapabilityFormatterTests: XCTestCase {
    let formatter = ProviderCapabilityFormatter()

    override func setUp() {
        super.setUp()
    }

    func testFormattingNoCapabilities() {
        let provider = Provider(
            capabilities: []
        )
        XCTAssertEqual(formatter.string(for: provider), "")
    }

    func testFormattingCheckingAccounts() {
        let provider = Provider(
            capabilities: [.checkingAccounts]
        )
        XCTAssertEqual(formatter.string(for: provider), "Checking Accounts")
    }

    func testFormattingCreditCards() {
        let provider = Provider(
            capabilities: [.creditCards]
        )
        XCTAssertEqual(formatter.string(for: provider), "Credit Cards")
    }

    func testFormattingCheckingAccountsAndCreditCards() {
        let provider = Provider(
            capabilities: [.checkingAccounts, .creditCards]
        )
        XCTAssertEqual(formatter.string(for: provider), "Checking Accounts & Credit Cards")
    }

    func testFormattingThreeCapabilities() {
        let provider = Provider(
            capabilities: [.checkingAccounts, .creditCards, .loans]
        )
        XCTAssertEqual(formatter.string(for: provider), "Checking Accounts, Credit Cards & Loans")
    }

    func testFormattingFourUnsortedCapabilities() {
        let provider = Provider(
            capabilities: [.identityData, .creditCards, .checkingAccounts, .loans]
        )
        XCTAssertEqual(formatter.string(for: provider), "Checking Accounts, Credit Cards, Loans & Identity Data")
    }

    func testFormattingForBeginningOfSentence() {
        let formatter = ProviderCapabilityFormatter()
        formatter.formattingContext = .beginningOfSentence
        let provider = Provider(
            capabilities: [.checkingAccounts, .creditCards, .loans]
        )
        XCTAssertEqual(formatter.string(for: provider), "Checking accounts, credit cards & loans")
    }

    func testFormattingForMiddleOfSentence() {
        let formatter = ProviderCapabilityFormatter()
        formatter.formattingContext = .middleOfSentence
        let provider = Provider(
            capabilities: [.checkingAccounts, .creditCards, .loans]
        )
        XCTAssertEqual(formatter.string(for: provider), "checking accounts, credit cards & loans")
    }

    func testLongStyleFormatting() {
        let formatter = ProviderCapabilityFormatter()
        formatter.listFormatter.style = .long
        let provider = Provider(
            capabilities: [.checkingAccounts, .creditCards, .loans]
        )
        XCTAssertEqual(formatter.string(for: provider), "Checking Accounts, Credit Cards and Loans")
    }
}
