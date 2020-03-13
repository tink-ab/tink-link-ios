@testable import TinkLink
import XCTest

class ProviderTreeTests: XCTestCase {
    func testCredentialTypesGrouping() {
        let providers = [MockerProvider.nordeaBankID, MockerProvider.nordeaPassword]

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
        let providers = [
            MockerProvider.nordeaOpenBanking,
            MockerProvider.nordeaBankID,
            MockerProvider.nordeaPassword
        ]

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
            MockerProvider.nordeaBankID,
            MockerProvider.nordeaPassword,
            MockerProvider.swedbankBankID,
            MockerProvider.swedbankPassword
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
            MockerProvider.nordeaBankID,
            MockerProvider.nordeaPassword,
            MockerProvider.sparbankernaBankID,
            MockerProvider.sparbankernaPassword,
            MockerProvider.swedbankBankID,
            MockerProvider.swedbankPassword
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
