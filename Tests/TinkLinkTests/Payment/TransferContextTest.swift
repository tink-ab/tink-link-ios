import Foundation
@testable import TinkLink
import XCTest

class TransferContextTests: XCTestCase {
    var mockedSuccessTransferService: TransferService!
    var mockedCancelledTransferService: TransferService!
    var mockedUnauthenticatedErrorTransferService: TransferService!

    var mockedSuccessBeneficiaryService: BeneficiaryService!
    var mockedCancelledBeneficiaryService: BeneficiaryService!
    var mockedUnauthenticatedErrorBeneficiaryService: BeneficiaryService!

    var mockedSuccessCredentialsService: CredentialsService!
    var mockedAuthenticationErrorCredentialsService: CredentialsService!
    var mockedUnauthenticatedErrorCredentialsService: CredentialsService!

    var mockedSuccessProviderService: ProviderService!

    var task: InitiateTransferTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))

        mockedSuccessTransferService = MockedSuccessTransferService()
        mockedCancelledTransferService = MockedCancelledTransferService()
        mockedUnauthenticatedErrorTransferService = MockedUnauthenticatedErrorTransferService()

        mockedSuccessBeneficiaryService = MockedSuccessBeneficiaryService()
        mockedCancelledBeneficiaryService = MockedCancelledBeneficiaryService()
        mockedUnauthenticatedErrorBeneficiaryService = MockedUnauthenticatedErrorBeneficiaryService()

        mockedSuccessCredentialsService = MockedSuccessPaymentCredentialsService()
        mockedAuthenticationErrorCredentialsService = MockedAuthenticationErrorCredentialsService()
        mockedUnauthenticatedErrorCredentialsService = MockedUnauthenticatedErrorCredentialsService()

        mockedSuccessProviderService = MockedSuccessProviderService()
    }

    func testFetchAccounts() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, beneficiaryService: mockedSuccessBeneficiaryService, credentialsService: mockedSuccessCredentialsService, providerService: mockedSuccessProviderService)
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
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, beneficiaryService: mockedSuccessBeneficiaryService, credentialsService: mockedSuccessCredentialsService, providerService: mockedSuccessProviderService)
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
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, beneficiaryService: mockedSuccessBeneficiaryService, credentialsService: mockedSuccessCredentialsService, providerService: mockedSuccessProviderService)
        transferContext.retryInterval = .leastNonzeroMagnitude

        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let initiateTransferCompletionCalled = expectation(description: "initiate transfer completion should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            message: InitiateTransferTask.Message(destination: "test"),
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
        let transferContext = TransferContext(tink: .shared, transferService: mockedCancelledTransferService, beneficiaryService: mockedSuccessBeneficiaryService, credentialsService: mockedSuccessCredentialsService, providerService: mockedSuccessProviderService)
        transferContext.retryInterval = .leastNonzeroMagnitude

        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let initiateTransferCancelledCalled = expectation(description: "initiate transfer completion with cancelled error should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            message: InitiateTransferTask.Message(destination: "test"),
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
        let transferContext = TransferContext(tink: .shared, transferService: mockedCancelledTransferService, beneficiaryService: mockedUnauthenticatedErrorBeneficiaryService, credentialsService: mockedAuthenticationErrorCredentialsService, providerService: mockedSuccessProviderService)
        transferContext.retryInterval = .leastNonzeroMagnitude

        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let initiateTransferUnauthenticatedError = expectation(description: "initiate transfer completion with cancelled error should be called")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            message: InitiateTransferTask.Message(destination: "test"),
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

    func testInitiateTransferFromAccountURI() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, beneficiaryService: mockedSuccessBeneficiaryService, credentialsService: mockedSuccessCredentialsService, providerService: mockedSuccessProviderService)
        transferContext.retryInterval = .leastNonzeroMagnitude

        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let initiateTransferCompletionCalled = expectation(description: "initiate transfer completion should be called")

        let uri = Account.URI(kind: .iban, accountNumber: "FR1420041010050015664355590")!

        task = transferContext.initiateTransfer(
            from: uri,
            to: Beneficiary.savingBeneficiary,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            message: InitiateTransferTask.Message(destination: "test"),
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

    func testInitiateTransferToBeneficiaryAccount() {
        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, beneficiaryService: mockedSuccessBeneficiaryService, credentialsService: mockedSuccessCredentialsService, providerService: mockedSuccessProviderService)
        transferContext.retryInterval = .leastNonzeroMagnitude
        
        let statusChangedToCreated = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let initiateTransferCompletionCalled = expectation(description: "initiate transfer completion should be called")

        let account = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")

        task = transferContext.initiateTransfer(
            from: Account.checkingTestAccount,
            to: account,
            amount: CurrencyDenominatedAmount(10, currencyCode: CurrencyCode("EUR")),
            message: InitiateTransferTask.Message(destination: "test"),
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
}
