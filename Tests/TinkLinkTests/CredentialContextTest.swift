import XCTest
@testable import TinkLink

class CredentialsContextTests: XCTestCase {
    var mockedSuccessCredentialService: MockedSuccessCredentialService!
    var mockedUnauthenticatedErrorCredentialService: MockedUnauthenticatedErrorCredentialService!

    override func setUp() {
        mockedSuccessCredentialService = MockedSuccessCredentialService()
        mockedUnauthenticatedErrorCredentialService = MockedUnauthenticatedErrorCredentialService()
    }

    func testAddingPasswordCredential() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))
        let credentialContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToupdating = expectation(description: "add credentials status should be changed to updating")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        let task = credentialContextUnderTest.addCredentials(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, progressHandler: { status in
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
}
