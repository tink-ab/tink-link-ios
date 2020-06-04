import Foundation
@testable import TinkLink
import XCTest

class AddBeneficiaryTaskTests: XCTestCase {
    var mockedSuccessTransferService: TransferService!

    var task: AddBeneficiaryTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))

        mockedSuccessTransferService = MockedSuccessTransferService()
    }

    func testSuccessfulAddBeneficiaryTask() {
        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentials])

        let account = Account.makeTestAccount(credentials: credentials)

        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, credentialsService: credentialsService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add beneficiary status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        task = transferContext.addBeneficiary(
            name: "Example Inc",
            accountNumberKind: .iban,
            accountNumber: "FR7630006000011234567890189",
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
                    addBeneficiaryCompletionCalled.fulfill()
                } catch {
                    XCTFail("Failed to add beneficiary with: \(error)")
                }
            }
        )

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testFailedAuthenticationAddBeneficiaryTask() {
        let credentials = Credentials.makeTestCredentials(
            providerID: "test-provider",
            kind: .password,
            status: .updated
        )

        let credentialsService = MutableCredentialsService(credentialsList: [credentials])
        credentialsService.credentialsStatusAfterSupplementalInformation = .authenticationError

        let account = Account.makeTestAccount(credentials: credentials)

        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, credentialsService: credentialsService)

        let statusChangedToRequestSent = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "add beneficiary status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add beneficiary status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "add beneficiary completion should be called")

        task = transferContext.addBeneficiary(
            name: "Example Inc",
            accountNumberKind: .iban,
            accountNumber: "FR7630006000011234567890189",
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
}
