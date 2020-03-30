@testable import TinkLink
import XCTest

class ProviderGRPCTests: XCTestCase {
    func testProviderMapping() {
        let restProvider = RESTProvider(
            accessType: .other,
            capabilities: [
                .loans,
                .savingsAccounts,
                .investments,
                .creditCards
            ],
            credentialsType: .thirdPartyApp,
            currency: "SEK",
            displayName: "Demo Unregulated Third party (successful)",
            displayDescription: "Third party app",
            fields: [RESTField(defaultValue: nil, _description: "Username", helpText: nil, hint: nil, immutable: true, masked: false, maxLength: nil, minLength: nil, name: "username", numeric: false, _optional: false, options: nil, pattern: nil, patternError: nil, value: nil, sensitive: false, checkbox: false, additionalInfo: nil)],
            financialInstitutionId: "946bd1966c1f5ef792a79f96b3d5facf",
            financialInstitutionName: "Demo Unregulated Third party (successful)",
            groupDisplayName: "Demo providers",
            images: RESTImageUrls(icon: "https://cdn.tink.se/provider-images/placeholder.png", banner: nil),
            market: "SE",
            multiFactor: true,
            name: "se-test-other-third-party-app-successful",
            passwordHelpText: "To connect your bank, you need to identify yourself using a third party app.",
            popular: false,
            status: .enabled,
            transactional: true,
            type: .test)

        let provider = Provider(restProvider: restProvider)

        XCTAssertEqual(provider.id.value, restProvider.name)
        XCTAssertEqual(provider.displayName, restProvider.displayName)
        XCTAssertEqual(provider.kind, .test)
        XCTAssertEqual(provider.status, .enabled)
        XCTAssertEqual(provider.credentialsKind, .thirdPartyAuthentication)
        XCTAssertFalse(provider.isPopular)
        XCTAssertEqual(provider.fields.count, 1)
        if let field = provider.fields.first {
            XCTAssertEqual(field.name, "username")
            XCTAssertEqual(field.fieldDescription, "Username")
            XCTAssertEqual(field.isImmutable, true)
        }
        XCTAssertEqual(provider.displayDescription, restProvider.displayDescription)
        XCTAssertEqual(provider.marketCode, restProvider.market)
        XCTAssertEqual(provider.accessType, .other)
        XCTAssertEqual(provider.financialInstitution.id.value, restProvider.financialInstitutionId)
        XCTAssertEqual(provider.financialInstitution.name, restProvider.financialInstitutionName)
    }

    func testCapabilitiesMapping() {
        let restCapabilities: [RESTProvider.Capabilities] = [.transfers, .checkingAccounts, .savingsAccounts]
        let capabilities = Provider.Capabilities(restCapabilities: restCapabilities)
        XCTAssertTrue(capabilities.contains(.checkingAccounts))
        XCTAssertEqual(Set(capabilities.restCapabilities), Set(restCapabilities))
    }

    func testCapabilitiesMatching() {
        let predicate: Provider.Capabilities = [.checkingAccounts, .savingsAccounts]
        XCTAssertFalse(predicate.isDisjoint(with: [.checkingAccounts, .creditCards]))
        XCTAssertTrue(predicate.isDisjoint(with: [.creditCards, .identityData]))
    }
}
