import XCTest
@testable import TinkLink
@testable import TinkCore

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
        task = credentialsContextUnderTest.add(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .authenticating, .awaitingSupplementalInformation, .awaitingThirdPartyAppAuthentication:
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
        task = credentialsContextUnderTest.add(for: Provider.testSupplementalInformation, form: Form(provider: Provider.testSupplementalInformation), completionPredicate: completionPredicate, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .awaitingSupplementalInformation(let supplementalInformationTask):
                statusChangedToAwaitingSupplementalInformation.fulfill()
                var form = Form(credentials: supplementalInformationTask.credentials)
                form.fields[0].text = "test"
                supplementalInformationTask.submit(form)
            case .updating:
                statusChangedToUpdating.fulfill()
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

    func testAddingThirdPartyAppAuthenticationCredentials() {
        let credentialsService = MockedSuccessThirdPartyAuthenticationCredentialsService()
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: credentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")
        let handledThirdPartyAppAuthenticationTask = expectation(description: "add credentials status should be changed to awaitingThirdPartyAppAuthentication")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialsContextUnderTest.add(for: Provider.testThirdPartyAuthentication, form: Form(provider: Provider.testThirdPartyAuthentication), completionPredicate: completionPredicate, progressHandler: { status in
            switch status {
            case .created:
                statusChangedToCreated.fulfill()
            case .awaitingThirdPartyAppAuthentication(let task):
                task.handle(with: MockedSuccessOpeningApplication()) { result in
                    do {
                        _ = try result.get()
                        handledThirdPartyAppAuthenticationTask.fulfill()
                    } catch {
                        XCTFail("Failed to handle third party app authentication task with: \(error)")
                    }
                }
            case .updating:
                statusChangedToUpdating.fulfill()
            case .authenticating, .awaitingSupplementalInformation:
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

    func testRefreshCredentialsAlreadyRefreshed() {
        let credentials = Credentials.makeTestCredentials(providerID: "test", kind: .password, status: .updated)
        let service = MutableCredentialsService(credentialsList: [credentials])

        service.credentialsStatusAfterRefresh = .updated

        let context = CredentialsContext(tink: .shared, credentialsService: service)

        let completionCalled = expectation(description: "Refresh credentials completion should be called with success")
        let task = context.refresh(credentials) { status in

        } completion: { result in
            do {
                let _ = try result.get()
                completionCalled.fulfill()
            } catch {
                XCTFail("Completion should be called with success. Got \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testRefreshCredentialsStuckInAwaiting() {

        let initialStatus = Credentials.Status.awaitingSupplementalInformation

        let credentials = Credentials.makeTestCredentials(providerID: "test", kind: .keyfob, status: initialStatus, supplementalInformationFields: [Provider.FieldSpecification(fieldDescription: "Code", hint: "", maxLength: nil, minLength: nil, isMasked: false, isNumeric: false, isImmutable: false, isOptional: false, name: "code", initialValue: "", pattern: "", patternError: "", helpText: "")])

        let service = MutableCredentialsService(credentialsList: [credentials])

        service.credentialsStatusAfterRefresh = initialStatus
        service.credentialsStatusAfterSupplementalInformation = .updated

        let context = CredentialsContext(tink: .shared, credentialsService: service)

        let completionCalled = expectation(description: "Refresh credentials completion should be called with success")
        let awaitingSupplementalInfoCalled = expectation(description: "Awaiting supplemental task status callback called")

        let task = context.refresh(credentials) { status in
            switch status {
            case .awaitingSupplementalInformation(let task):
                awaitingSupplementalInfoCalled.fulfill()
                var form = Form(credentials: task.credentials)
                form.fields[0].text = "test"
                task.submit(form)
            default:
                XCTFail()
            }
        } completion: { result in
            do {
                let _ = try result.get()
                completionCalled.fulfill()
            } catch {
                XCTFail("Completion should be called with success. Got \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }
}
