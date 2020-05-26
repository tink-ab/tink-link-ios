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

    func testFetchAccounts() {
        let fetchAccountsCompletionCalled = expectation(description: "fetch accounts completion should be called")

        mockedSuccessTransferService.accounts(destinationUris: []) { result in
            do {
                _ = try result.get()
                fetchAccountsCompletionCalled.fulfill()
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

    func testFetchBeneficiaries() {
        let fetchBeneficiariesCompletionCalled = expectation(description: "fetch beneficiaries completion should be called")

        mockedSuccessTransferService.beneficiaries { result in
            do {
                _ = try result.get()
                fetchBeneficiariesCompletionCalled.fulfill()
            } catch {
                XCTFail("Failed to fetch beneficiaries with: \(error)")
            }
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
