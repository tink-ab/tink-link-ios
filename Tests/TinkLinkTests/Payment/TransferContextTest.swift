import Foundation
@testable import TinkLink
import XCTest

class TransferContextTests: XCTestCase {
    var mockedSuccessTransferService: MockedSuccessTransferService!
    var mockedUnauthenticatedErrorTransferService: MockedUnauthenticatedErrorTransferService!
    var task: AddCredentialsTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))
        mockedSuccessTransferService = MockedSuccessTransferService()
        mockedUnauthenticatedErrorTransferService = MockedUnauthenticatedErrorTransferService()
    }

    func testFetchAccount() {
        let fetchAccountCompletionCalled = expectation(description: "fetch accounts completion should be called")

        mockedSuccessTransferService.accounts(destinationUris: []) { result in
            do {
                _ = try result.get()
                fetchAccountCompletionCalled.fulfill()
            } catch {
                XCTFail("Failed to fetch accounts with: \(error)")
            }
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
