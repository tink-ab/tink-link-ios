import XCTest
@testable import TinkLink

class CredentialsContextTests: XCTestCase {
    var mockedSuccessCredentialsService: CredentialsService!
    var mockedUnauthenticatedErrorCredentialsService: CredentialsService!
    var task: AddCredentialsTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))
        mockedSuccessCredentialsService = MockedSuccessCredentialsService()
        mockedUnauthenticatedErrorCredentialsService = MockedUnauthenticatedErrorCredentialsService()
    }

    func testAddingPasswordCredentials() {
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialsContextUnderTest.add(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, authenticationHandler: { task in
            return
        }, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .authenticating:
                break
            case .updating:
                statusChangedToUpdating.fulfill()
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
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")
        let statusChangedToAwaitingSupplementalInformation = expectation(description: "add credentials status should be changed to awaitingSupplementalInformation")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialsContextUnderTest.add(for: Provider.testSupplementalInformation, form: Form(provider: Provider.testSupplementalInformation), completionPredicate: completionPredicate, authenticationHandler: { task in
            switch task {
            case .awaitingSupplementalInformation(let task):
                statusChangedToAwaitingSupplementalInformation.fulfill()
                var form = Form(credentials: task.credentials)
                form.fields[0].text = "test"
                task.submit(form)
            case .awaitingThirdPartyAppAuthentication:
                break
            }
        }, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .updating:
                statusChangedToUpdating.fulfill()
            case .authenticating:
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

    func testAddingThirdPartyAppAuthenticationCredentials() {
        let credentialsService = MockedSuccessThirdPartyAuthenticationCredentialsService()
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: credentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")
        let handledThirdPartyAppAuthenticationTask = expectation(description: "add credentials status should be changed to awaitingThirdPartyAppAuthentication")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialsContextUnderTest.add(for: Provider.testThirdPartyAuthentication, form: Form(provider: Provider.testThirdPartyAuthentication), completionPredicate: completionPredicate, authenticationHandler: { task in
            switch task {
            case .awaitingSupplementalInformation:
                break
            case .awaitingThirdPartyAppAuthentication(let task):
                task.handle(with: MockedSuccessOpeningApplication()) { result in
                    do {
                        _ = try result.get()
                        handledThirdPartyAppAuthenticationTask.fulfill()
                    } catch {
                        XCTFail("Failed to handle third party app authentication task with: \(error)")
                    }
                }
            }
        }, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .updating:
                statusChangedToUpdating.fulfill()
            case .authenticating:
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

    func testAddingCredentialsWithoutRetainingTask() {
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        
        credentialsContextUnderTest.add(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, authenticationHandler: { task in
            return
        }, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .authenticating:
                break
            case .updating:
                statusChangedToUpdating.fulfill()
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
        }    }
}
