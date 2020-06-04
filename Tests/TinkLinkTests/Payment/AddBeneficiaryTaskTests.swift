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

        let statusChangedToRequestSent = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "initiate transfer completion should be called")

        task = transferContext.addBeneficiary(
            name: "Example Inc",
            accountNumberKind: .iban,
            accountNumber: "FR7630006000011234567890189",
            to: account,
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
                case .requestSent:
                    statusChangedToRequestSent.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    credentialsService.modifyCredentials(id: credentials.id, status: .awaitingSupplementalInformation, supplementalInformationFields: [])
                }
            }
        ) { result in
            do {
                _ = try result.get()
                addBeneficiaryCompletionCalled.fulfill()
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
