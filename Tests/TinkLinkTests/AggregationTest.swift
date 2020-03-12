import XCTest
@testable import TinkLink

class AggregationTest: XCTestCase {
    var tink: Tink!
    var user: User?

    override func setUp() {
        // TODO: inject the cliendID from CI
        let clientID = ProcessInfo.processInfo.environment["TINK_LINK_TESTER_CLIENT_ID"] ?? "459d8c78f41f4c7ab1a66a4fc06ff82f"
        let configuration = try! Tink.Configuration(clientID: clientID, redirectURI: URL(string: "link-demo://tink")!, environment: .production)
        tink = Tink(configuration: configuration)
    }

    func testCreateAnonymousUser() {
        let completionCalled = expectation(description: "completion should be called")

        let userContext = UserContext(tink: tink)
        userContext.createTemporaryUser(for: "SE") { [weak self] result in
            completionCalled.fulfill()
            do {
                self?.user = try result.get()
            } catch {
                XCTFail("Failed to get user with: \(error)")
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testFetchProviders() {
        if user == nil {
            testCreateAnonymousUser()
        }

        guard let temporaryUser = user else {
            return
        }

        let completionCalled = expectation(description: "completion should be called")

        let providerContext = ProviderContext(tink: tink, user: temporaryUser)
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        providerContext.fetchProviders(attributes: attributes) { result in
            completionCalled.fulfill()
            do {
                let providers = try result.get()
                if let passwordTestProvider = providers.first(where: { $0.id == "se-test-password" }) {
                    XCTAssertEqual(passwordTestProvider.displayName, "Test Password")
                    XCTAssertEqual(passwordTestProvider.kind, Provider.Kind.test)
                    XCTAssertEqual(passwordTestProvider.credentialKind, Credential.Kind.password)
                } else {
                    XCTFail("Failed to get test provider")
                }
            } catch {
                XCTFail("Failed to get provider list with: \(error)")
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
