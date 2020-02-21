@testable import TinkLink
import XCTest

class ProviderTreeTests: XCTestCase {
    let nordeaBankID = Provider(
        id: "nordea-bankid",
        displayName: "Nordea",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Nordea",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1266),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "dde2463acf40501389de4fca5a3693a4", name: "Nordea")
    )

    let nordeaPassword = Provider(
        id: "nordea-password",
        displayName: "Nordea",
        kind: .bank,
        status: .enabled,
        credentialKind: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Nordea",
        image: nil,
        displayDescription: "Password",
        capabilities: .init(rawValue: 1266),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "dde2463acf40501389de4fca5a3693a4", name: "Nordea")
    )

    let nordeaOpenBanking = Provider(
        id: "se-nordea-ob",
        displayName: "Nordea Open Banking",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Nordea",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1266),
        accessType: .openBanking,
        marketCode: "SE",
        financialInstitution: .init(id: "dde2463acf40501389de4fca5a3693a4", name: "Nordea")
    )

    let sparbankernaBankID = Provider(
        id: "savingsbank-bankid",
        displayName: "Sparbankerna",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "a0afa9bbc85c52aba1b1b8d6a04bc57c", name: "Sparbankerna")
    )

    let sparbankernaPassword = Provider(
        id: "savingsbank-token",
        displayName: "Sparbankerna",
        kind: .bank,
        status: .enabled,
        credentialKind: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Security token",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "a0afa9bbc85c52aba1b1b8d6a04bc57c", name: "Sparbankerna")
    )

    let swedbankBankID = Provider(
        id: "swedbank-bankid",
        displayName: "Swedbank",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "6c1749b4475e5677a83e9fa4bb60a18a", name: "Swedbank")
    )

    let swedbankPassword = Provider(
        id: "swedbank-token",
        displayName: "Swedbank",
        kind: .bank,
        status: .enabled,
        credentialKind: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Security token",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "6c1749b4475e5677a83e9fa4bb60a18a", name: "Swedbank")
    )

    func testCredentialTypesGrouping() {
        let providers = [nordeaBankID, nordeaPassword]

        let tree = ProviderTree(providers: providers)
        let groups = tree.financialInstitutionGroups

        XCTAssertEqual(groups.count, 1)
        for group in groups {
            switch group {
            case .credentialKinds(let providers):
                XCTAssertEqual(providers.count, 2)
            default:
                XCTFail("Expected credential types group.")
            }
        }
    }

    func testAccessTypeGrouping() {
        let providers = [nordeaOpenBanking, nordeaBankID, nordeaPassword]

        let tree = ProviderTree(providers: providers)
        let groups = tree.financialInstitutionGroups

        XCTAssertEqual(groups.count, 1)
        if let nordeaGroup = groups.first {
            switch nordeaGroup {
            case .accessTypes(let accessTypeGroups):
                XCTAssertEqual(accessTypeGroups.count, 2)
                if let openBankingAccessTypeGroup = accessTypeGroups.first(where: { $0.accessType == .openBanking }) {
                    switch openBankingAccessTypeGroup {
                    case .provider(let provider):
                        XCTAssertEqual(provider.id, nordeaOpenBanking.id)
                    default:
                        XCTFail("Expected provider group.")
                    }
                }
                if let otherAccessTypeGroup = accessTypeGroups.first(where: { $0.accessType == .other }) {
                    switch otherAccessTypeGroup {
                    case .credentialKinds(let providers):
                        XCTAssertEqual(providers.count, 2)
                    default:
                        XCTFail("Expected credential types group.")
                    }
                }
            default:
                XCTFail("Expected credential types group.")
            }
        } else {
            XCTFail()
        }
    }

    func testGroupDisplayNameGrouping() {
        let providers = [
            nordeaBankID,
            nordeaPassword,
            swedbankBankID,
            swedbankPassword
        ]

        let tree = ProviderTree(providers: providers)
        let groups = tree.financialInstitutionGroups

        XCTAssertEqual(groups.count, 2)

        let nordeaGroup = groups[0]
        switch nordeaGroup {
        case .credentialKinds(let providers):
            XCTAssertEqual(providers.count, 2)
        default:
            XCTFail("Expected credential types group.")
        }

        let swedbankAndSparbankernaGroup = groups[1]
        switch swedbankAndSparbankernaGroup {
        case .credentialKinds(let providers):
            XCTAssertEqual(providers.count, 2)
        default:
            XCTFail("Expected credential types group.")
        }
    }

    func testGroupDisplayNameAndFinancialInstitutionGrouping() {
        let providers = [
            nordeaBankID,
            nordeaPassword,
            sparbankernaBankID,
            sparbankernaPassword,
            swedbankBankID,
            swedbankPassword
        ]

        let tree = ProviderTree(providers: providers)
        let groups = tree.financialInstitutionGroups

        XCTAssertEqual(groups.count, 2)

        let nordeaGroup = groups[0]
        switch nordeaGroup {
        case .credentialKinds(let providers):
            XCTAssertEqual(providers.count, 2)
        default:
            XCTFail("Expected credential types group.")
        }

        let swedbankAndSparbankernaGroup = groups[1]
        switch swedbankAndSparbankernaGroup {
        case .financialInstitutions(let financialInstitutions):
            XCTAssertEqual(financialInstitutions.count, 2)
            for financialInstitution in financialInstitutions {
                switch financialInstitution {
                case .credentialKinds(let providers):
                    XCTAssertEqual(providers.count, 2)
                default:
                    XCTFail("Expected credential types group.")
                }
            }
        default:
            XCTFail("Expected financial institutions group.")
        }
    }
}
