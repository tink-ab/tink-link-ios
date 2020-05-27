import Foundation
@testable import TinkLink
import XCTest

class TransferContextTests: XCTestCase {
    var mockedSuccessTransferService: TransferService!
    var mockedCancelledTransferService: TransferService!
    var mockedUnauthenticatedErrorTransferService: TransferService!

    var mockedSuccessCredentialsService: CredentialsService!
    var mockedAuthenticationErrorCredentialsService: CredentialsService!
    var mockedUnauthenticatedErrorCredentialsService: CredentialsService!

    var task: InitiateTransferTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))

        mockedSuccessTransferService = MockedSuccessTransferService()
        mockedCancelledTransferService = MockedCancelledTransferService()
        mockedUnauthenticatedErrorTransferService = MockedUnauthenticatedErrorTransferService()

        mockedSuccessCredentialsService = MockedSuccessPaymentCredentialsService()
        mockedAuthenticationErrorCredentialsService = MockedAuthenticationErrorCredentialsService()
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
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let initiateTransferCompletionCalled = expectation(description: "initiate transfer completion should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            destinationMessage: "test",
            authentication: { task in
                switch task {
                case .awaitingThirdPartyAppAuthentication: break
                case .awaitingSupplementalInformation(let supplementInformationTask):
                    let form = Form(credentials: supplementInformationTask.credentials)
                    supplementInformationTask.submit(form)
                    statusChangedToAwaitingSupplementalInformation.fulfill()
                }
            },
            progress: { status in
                switch status {
                case .created:
                    statusChangedToCreated.fulfill()
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
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

    func testInitiateTransferThatGetCancelled() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedCancelledTransferService, credentialsService: mockedSuccessCredentialsService)
        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let initiateTransferCancelledCalled = expectation(description: "initiate transfer completion with cancelled error should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            destinationMessage: "test",
            authentication: { task in
                switch task {
                case .awaitingThirdPartyAppAuthentication: break
                case .awaitingSupplementalInformation(let supplementInformationTask):
                    let form = Form(credentials: supplementInformationTask.credentials)
                    supplementInformationTask.submit(form)
                    statusChangedToAwaitingSupplementalInformation.fulfill()
                }
            },
            progress: { status in
                switch status {
                case .created:
                    statusChangedToCreated.fulfill()
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                default:
                    break
                }
            }
        ) { result in
            do {
                _ = try result.get()
                XCTFail("Initiate transfer should be cancelled")
            } catch {
                if let initiateTransferTaskError = error as? InitiateTransferTask.Error {
                    switch initiateTransferTaskError {
                    case .cancelled:
                        initiateTransferCancelledCalled.fulfill()
                    default:
                        XCTFail("Failed to initiate transfer with: \(error)")
                    }
                }
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testInitiateTransferWithUnauthenticatedError() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedCancelledTransferService, credentialsService: mockedAuthenticationErrorCredentialsService)
        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let initiateTransferUnauthenticatedError = expectation(description: "initiate transfer completion with cancelled error should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            destinationMessage: "test",
            authentication: { _ in },
            progress: { status in
                switch status {
                case .created:
                    statusChangedToCreated.fulfill()
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                default:
                    break
                }
        }
        ) { result in
            do {
                _ = try result.get()
                XCTFail("Initiate transfer should be failed")
            } catch {
                if let initiateTransferTaskError = error as? InitiateTransferTask.Error {
                    switch initiateTransferTaskError {
                    case .authenticationFailed:
                        initiateTransferUnauthenticatedError.fulfill()
                    default:
                        XCTFail("Failed to initiate transfer with: \(error)")
                    }
                }
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

}
