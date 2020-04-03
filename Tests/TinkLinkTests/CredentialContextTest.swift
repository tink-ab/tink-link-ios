import XCTest
@testable import TinkLink

class CredentialsContextTests: XCTestCase {
    var mockedSuccessCredentialsService: MockedSuccessCredentialsService!
    var mockedUnauthenticatedErrorCredentialsService: MockedUnauthenticatedErrorCredentialsService!
    var task: AddCredentialsTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))
        mockedSuccessCredentialsService = MockedSuccessCredentialsService()
        mockedUnauthenticatedErrorCredentialsService = MockedUnauthenticatedErrorCredentialsService()
    }

    func testAddingPasswordCredentials() {
        let credentialContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToupdating = expectation(description: "add credentials status should be changed to updating")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialContextUnderTest.add(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .authenticating, .awaitingSupplementalInformation, .awaitingThirdPartyAppAuthentication:
                break
            case .updating:
                statusChangedToupdating.fulfill()
            }
        }) { result in
            do {
                _ = try result.get()
                addCredentialsCompletionCalled.fulfill()
            } catch {
                XCTFail("Failed to create credentials with: \(error)")
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testAddingSupplementalInfoCredentials() {
        let credentialContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToupdating = expectation(description: "add credentials status should be changed to updating")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add credentials status should be changed to awaitingSupplementalInformation")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialContextUnderTest.add(for: Provider.testSupplementalInformation, form: Form(provider: Provider.testSupplementalInformation), completionPredicate: completionPredicate, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .awaitingSupplementalInformation(let supplementalInformationTask):
                statusChangedToAwaitingSupplementalInformation.fulfill()
                var form = Form(credentials: supplementalInformationTask.credentials)
                form.fields[0].text = "test"
                supplementalInformationTask.submit(form)
            case .updating:
                statusChangedToupdating.fulfill()
            case .authenticating, .awaitingThirdPartyAppAuthentication:
                break
            }
        }) { result in
            do {
                _ = try result.get()
                addCredentialsCompletionCalled.fulfill()
            } catch {
                XCTFail("Failed to create credentials with: \(error)")
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
