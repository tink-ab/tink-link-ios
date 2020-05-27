import Foundation
@testable import TinkLink
import XCTest

class TransferContextTests: XCTestCase {
    var mockedSuccessTransferService: MockedSuccessTransferService!
    var mockedUnauthenticatedErrorTransferService: MockedUnauthenticatedErrorTransferService!

    var mockedSuccessCredentialsService: MockedSuccessCredentialsServiceForPayment!
    var mockedUnauthenticatedErrorCredentialsService: MockedUnauthenticatedErrorCredentialsService!

    var task: InitiateTransferTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))

        mockedSuccessTransferService = MockedSuccessTransferService()
        mockedUnauthenticatedErrorTransferService = MockedUnauthenticatedErrorTransferService()
        mockedSuccessCredentialsService = MockedSuccessCredentialsServiceForPayment()
        mockedUnauthenticatedErrorCredentialsService = MockedUnauthenticatedErrorCredentialsService()
    }

    func testFetchAccounts() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, credentialsService: mockedSuccessCredentialsService)
        let fetchAccountsCompletionCalled = expectation(description: "fetch accounts completion should be called")

        _ = transferContext.fetchAccounts { result in
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

    func testFetchAllBeneficiaries() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, credentialsService: mockedSuccessCredentialsService)
        let fetchBeneficiariesCompletionCalled = expectation(description: "fetch beneficiaries completion should be called")
        _ = transferContext.fetchBeneficiaries { result in
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

    func testInitiateTransfer() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, credentialsService: mockedSuccessCredentialsService)
        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let initiateTransferCompletionCalled = expectation(description: "initiate transfer completion should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            message: TransferMessage(destination: "test"),
            authentication: { _ in },
            progress: { status in
                switch status {
                case .created:
                    statusChangedToCreated.fulfill()
                case .authenticating:
                    print("something happen here")
                default:
                    break
                }
            }
        ) { result in
            do {
                _ = try result.get()
                initiateTransferCompletionCalled.fulfill()
            } catch {
                XCTFail("Failed to initiate transfer with: \(error)")
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
