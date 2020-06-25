@testable import TinkLink
import XCTest

class ProviderRESTTests: XCTestCase {
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
            type: .test
        )

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

    func testProviderMappingWithNewCapabilities() throws {
        let testProviderJSON = """
        {
            "accessType": "OPEN_BANKING",
            "authenticationUserType": "PERSONAL",
            "capabilities": ["CREDIT_CARDS", "TEST_CAPABILITIES"],
            "credentialsType": "THIRD_PARTY_APP",
            "currency": "SEK",
            "displayName": "Demo Open Banking Decoupled",
            "displayDescription": "TEST",
            "fields": [
                {
                    "defaultValue": null,
                    "description": "Nom d'utilisateur",
                    "exposed": true,
                    "children": null,
                    "helpText": null,
                    "hint": null,
                    "immutable": true,
                    "masked": false,
                    "maxLength": null,
                    "minLength": null,
                    "name": "username",
                    "numeric": false,
                    "optional": false,
                    "options": null,
                    "pattern": null,
                    "patternError": null,
                    "type": null,
                    "value": null,
                    "sensitive": false,
                    "checkbox": false,
                    "additionalInfo": null
                }
            ],
            "financialInstitutionId": "dbcebf1e6b575dd787532560cc9638b7",
            "financialInstitutionName": "Demo Open Banking Decoupled",
            "groupDisplayName": "Demo providers",
            "images": {
                "icon": "https://cdn.tink.se/provider-images/placeholder.png",
                "banner": null
            },
            "market": "SE",
            "multiFactor": true,
            "name": "se-test-open-banking-decoupled-successful",
            "passwordHelpText": "TEST.",
            "popular": false,
            "status": "ENABLED",
            "transactional": true,
            "type": "TEST"
        }
        """
        guard let data = testProviderJSON.data(using: .utf8) else {
            XCTFail("Failed to parse the JSON")
            return
        }
        let provider = try JSONDecoder().decode(RESTProvider.self, from: data)
        XCTAssertTrue(provider.capabilities.contains(.creditCards))
        XCTAssertTrue(provider.capabilities.contains(.unknown))
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
