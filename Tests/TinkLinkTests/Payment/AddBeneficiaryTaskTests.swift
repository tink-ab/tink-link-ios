import Foundation
@testable import TinkLink
import XCTest

class AddBeneficiaryTaskTests: XCTestCase {
    var mockedSuccessTransferService: TransferService!

    var credentialsService: MutableCredentialsService!

    var task: AddBeneficiaryTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))

        mockedSuccessTransferService = MockedSuccessTransferService()

        credentialsService = MutableCredentialsService()
    }

    func testSuccessfulAddBeneficiaryTask() {
        let credentials = Credentials(
            id: Credentials.ID(UUID().uuidString),
            providerID: Provider.ID("test-provider"),
            kind: .password,
            status: .updated,
            statusPayload: "",
            statusUpdated: Date(),
            updated: Date(),
            fields: ["username": "test", "password": "12345678"],
            supplementalInformationFields: [],
            thirdPartyAppAuthentication: nil,
            sessionExpiryDate: nil
        )

        let account = Account(
            accountNumber: "FR1420041010050015664355590",
            balance: 68.61,
            credentialsID: credentials.id,
            isFavored: false,
            id: Account.ID(UUID().uuidString),
            name: "Checking Account tink 1",
            ownership: 1.0,
            kind: .checking,
            transferSourceIdentifiers: [URL(string: "iban://FR1420041010050015664355590?name=testAccount")!],
            transferDestinations: nil,
            details: nil,
            holderName: nil,
            isClosed: false,
            flags: [],
            accountExclusion: nil,
            currencyDenominatedBalance: CurrencyDenominatedAmount(Decimal(68.61), currencyCode: CurrencyCode("EUR")),
            refreshed: Date(),
            financialInstitutionID: Provider.FinancialInstitution.ID(UUID().uuidString)
        )

        credentialsService.credentialsByID = [credentials.id: credentials]

        let transferContext = TransferContext(tink: .shared, transferService: mockedSuccessTransferService, credentialsService: credentialsService)

        let statusChangedToRequestSent = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAuthenticating = expectation(description: "initiate transfer status should be changed to created")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "initiate transfer status should be changed to awaitingSupplementalInformation")
        let addBeneficiaryCompletionCalled = expectation(description: "initiate transfer completion should be called")

        task = transferContext.addBeneficiary(
            to: account,
            name: "Example Inc",
            accountNumberType: "iban",
            accountNumber: "FR7630006000011234567890189",
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
                    self.credentialsService.modifyCredentials(id: credentials.id, status: .authenticating)
                case .authenticating:
                    statusChangedToAuthenticating.fulfill()
                    self.credentialsService.modifyCredentials(id: credentials.id, status: .awaitingSupplementalInformation, supplementalInformationFields: [])
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
