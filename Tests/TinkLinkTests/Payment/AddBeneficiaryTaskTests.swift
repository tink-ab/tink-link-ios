import Foundation
@testable import TinkLink
import XCTest

class AddBeneficiaryTaskTests: XCTestCase {
    var task: AddBeneficiaryTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))
    }

    func testAddingBeneficiaryWithSupplementalInformationAuthentication() {
        let transferService = MutableTransferService(accounts: [], beneficiaries: [])
        let providerService = MockedSuccessProviderService()

        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentials])

        let account = Account.makeTestAccount(credentials: credentials)

        let transferContext = TransferContext(tink: .shared, transferService: transferService, credentialsService: credentialsService, providerService: providerService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add beneficiary status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        let beneficiaryAccount = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")

        task = transferContext.addBeneficiary(
            account: beneficiaryAccount,
            name: "Example Inc",
            to: account,
            authentication: { task in
                switch task {
                case .awaitingThirdPartyAppAuthentication:
                    XCTFail("Didn't expect a third party app authentication task")
                case .awaitingSupplementalInformation(let supplementInformationTask):
                    let form = Form(supplementInformationTask: supplementInformationTask)
                    supplementInformationTask.submit(form)
                    statusChangedToAwaitingSupplementalInformation.fulfill()
                }
            },
            progress: { status in
                switch status {
                case .requestSent:
                    statusChangedToRequestSent.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .awaitingSupplementalInformation, supplementalInformationFields: [])
                }
            },
            completion: { result in
                do {
                    _ = try result.get()
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
                addBeneficiaryCompletionCalled.fulfill()
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testAddingBeneficiaryThatFailsSupplementalInformationAuthentication() {
        let transferService = MutableTransferService(accounts: [], beneficiaries: [])
        let providerService = MockedSuccessProviderService()

        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentials])
        credentialsService.credentialsStatusAfterSupplementalInformation = .authenticationError

        let account = Account.makeTestAccount(credentials: credentials)

        let transferContext = TransferContext(tink: .shared, transferService: transferService, credentialsService: credentialsService, providerService: providerService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add beneficiary status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        let beneficiaryAccount = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")

        task = transferContext.addBeneficiary(
            account: beneficiaryAccount,
            name: "Example Inc",
            to: account,
            authentication: { task in
                switch task {
                case .awaitingThirdPartyAppAuthentication:
                    XCTFail("Didn't expect a third party app authentication task")
                case .awaitingSupplementalInformation(let supplementInformationTask):
                    let form = Form(supplementInformationTask: supplementInformationTask)
                    supplementInformationTask.submit(form)
                    statusChangedToAwaitingSupplementalInformation.fulfill()
                }
            },
            progress: { status in
                switch status {
                case .requestSent:
                    statusChangedToRequestSent.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .awaitingSupplementalInformation, supplementalInformationFields: [])
                }
            },
            completion: { result in
                do {
                    _ = try result.get()
                    XCTFail("Expected task to fail.")
                } catch AddBeneficiaryTask.Error.authenticationFailed(let message) {
                    XCTAssertEqual(message, "")
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
                addBeneficiaryCompletionCalled.fulfill()
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testAddingBeneficiaryWithNoAuthenticationStep() {
        let transferService = MutableTransferService(accounts: [], beneficiaries: [])
        let providerService = MockedSuccessProviderService()

        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentials])

        let account = Account.makeTestAccount(credentials: credentials)

        let transferContext = TransferContext(tink: .shared, transferService: transferService, credentialsService: credentialsService, providerService: providerService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        let beneficiaryAccount = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")

        task = transferContext.addBeneficiary(
            account: beneficiaryAccount,
            name: "Example Inc",
            to: account,
            authentication: { task in
                XCTFail("Didn't expect an authentication task")
            },
            progress: { status in
                switch status {
                case .requestSent:
                    statusChangedToRequestSent.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .updated)
                }
            },
            completion: { result in
                do {
                    _ = try result.get()
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
                addBeneficiaryCompletionCalled.fulfill()
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testAddingBeneficiaryWithDifferentCredentialsThanAccount() {
        let transferService = MutableTransferService(accounts: [], beneficiaries: [])
        let providerService = MockedSuccessProviderService()

        let credentialsWithoutCapability = Credentials.makeTestCredentials(
            providerID: "test-provider-a",
            kind: .password,
            status: .updated
        )

        let credentialsWithCapability = Credentials.makeTestCredentials(
            providerID: "test-provider-b",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentialsWithoutCapability, credentialsWithCapability])

        let account = Account.makeTestAccount(credentials: credentialsWithoutCapability)

        XCTAssertEqual(account.credentialsID, credentialsWithoutCapability.id)
        XCTAssertNotEqual(account.credentialsID, credentialsWithCapability.id)

        let transferContext = TransferContext(tink: .shared, transferService: transferService, credentialsService: credentialsService, providerService: providerService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        let beneficiaryAccount = BeneficiaryAccount.iban("FR7630006000011234567890189")

        task = transferContext.addBeneficiary(
            account: beneficiaryAccount,
            name: "Example Inc",
            to: account,
            credentials: credentialsWithCapability,
            authentication: { task in
                XCTFail("Didn't expect an authentication task")
            },
            progress: { status in
                switch status {
                case .requestSent:
                    statusChangedToRequestSent.fulfill()
                    credentialsService.modifyCredentials(id: credentialsWithCapability.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    credentialsService.modifyCredentials(id: credentialsWithCapability.id, status: .updated)
                }
            },
            completion: { result in
                do {
                    _ = try result.get()
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
                addBeneficiaryCompletionCalled.fulfill()
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testAddingBeneficiaryWithMultipleAuthenticationTasks() {
        let transferService = MutableTransferService(accounts: [], beneficiaries: [])
        let providerService = MockedSuccessProviderService()

        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentials])

        let account = Account.makeTestAccount(credentials: credentials)

        let transferContext = TransferContext(tink: .shared, transferService: transferService, credentialsService: credentialsService, providerService: providerService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAwaitingThirdPartyAppAuthentication = expectation(description: "add beneficiary status should be changed to awaitingSupplementalInformation")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add beneficiary status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        let beneficiaryAccount = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")

        task = transferContext.addBeneficiary(
            account: beneficiaryAccount,
            name: "Example Inc",
            to: account,
            authentication: { task in
                switch task {
                case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
                    thirdPartyAppAuthenticationTask._complete(with: .success)
                    credentialsService.modifyCredentials(id: credentials.id, status: .awaitingSupplementalInformation, supplementalInformationFields: [])
                    statusChangedToAwaitingThirdPartyAppAuthentication.fulfill()
                case .awaitingSupplementalInformation(let supplementInformationTask):
                    let form = Form(supplementInformationTask: supplementInformationTask)
                    supplementInformationTask.submit(form)
                    statusChangedToAwaitingSupplementalInformation.fulfill()
                }
            },
            progress: { status in
                switch status {
                case .requestSent:
                    statusChangedToRequestSent.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    let thirdPartyAppAuthentication = Credentials.ThirdPartyAppAuthentication(
                        downloadTitle: nil,
                        downloadMessage: nil,
                        upgradeTitle: nil,
                        upgradeMessage: nil,
                        appStoreURL: nil,
                        scheme: nil,
                        deepLinkURL: URL(string: "app://test")
                    )
                    credentialsService.modifyCredentials(id: credentials.id, status: .awaitingThirdPartyAppAuthentication, thirdPartyAppAuthentication: thirdPartyAppAuthentication)
                }
            },
            completion: { result in
                do {
                    _ = try result.get()
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
                addBeneficiaryCompletionCalled.fulfill()
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testAddingBeneficiaryUnauthenticated() {
        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )
        let account = Account.makeTestAccount(credentials: credentials)

        let credentialsService = MockedAuthenticationErrorCredentialsService()
        let transferService = MockedUnauthenticatedErrorTransferService()
        let providerService = MockedUnauthenticatedErrorProviderService()

        let transferContext = TransferContext(tink: .shared, transferService: transferService, credentialsService: credentialsService, providerService: providerService)

        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        let beneficiaryAccount = BeneficiaryAccount(accountNumberKind: .iban, accountNumber: "FR7630006000011234567890189")

        task = transferContext.addBeneficiary(
            account: beneficiaryAccount,
            name: "Example Inc",
            to: account,
            authentication: { task in
                XCTFail("Didn't expect an authentication task")
            },
            progress: { status in
                XCTFail("Didn't expect any status")
            },
            completion: { result in
                do {
                    _ = try result.get()
                    XCTFail("Expected failure.")
                } catch ServiceError.unauthenticated {
                    XCTAssertTrue(true)
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
                addBeneficiaryCompletionCalled.fulfill()
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
