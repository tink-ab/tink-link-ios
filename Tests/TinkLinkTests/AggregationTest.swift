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
        var completedCalled = expectation(description: "completed should be called")

        let userContext = UserContext(tink: tink)
        userContext.createTemporaryUser(for: "SE") { result in
            completedCalled.fulfill()
            do {
                let user = try result.get()
                self.user = user
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
}
