import XCTest
@testable import TinkLink
@testable import TinkCore

class CredentialsContextTests: XCTestCase {
    var mockedSuccessCredentialsService: CredentialsService!
    var mockedUnauthenticatedErrorCredentialsService: CredentialsService!
    var task: Cancellable?

    override func setUp() {
        Tink.configure(
            with: TinkLinkConfiguration(
                clientID: "testID",
                appURI: URL(string: "app://callback")!
            )
        )
        mockedSuccessCredentialsService = MockedSuccessCredentialsService()
        mockedUnauthenticatedErrorCredentialsService = MockedUnauthenticatedErrorCredentialsService()
    }

    func testAddingPasswordCredentials() {
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)
        credentialsContextUnderTest.pollingStrategy = .constant(.leastNonzeroMagnitude)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)
        task = credentialsContextUnderTest.add(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, authenticationHandler: { task in
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
        credentialsContextUnderTest.pollingStrategy = .constant(.leastNonzeroMagnitude)

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
        credentialsContextUnderTest.pollingStrategy = .constant(.leastNonzeroMagnitude)

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

    func testRefreshCredentialsAlreadyRefreshed() {
        let credentials = Credentials.makeTestCredentials(providerName: "test", kind: .password, status: .updated)
        let service = MutableCredentialsService(credentialsList: [credentials])

        service.credentialsStatusAfterRefresh = .updated

        let context = CredentialsContext(tink: .shared, credentialsService: service)
        context.pollingStrategy = .constant(.leastNonzeroMagnitude)

        let completionCalled = expectation(description: "Refresh credentials completion should be called with success")
        task = context.refresh(credentials) { status in

        } completion: { result in
            do {
                _ = try result.get()
                completionCalled.fulfill()
            } catch {
                XCTFail("Completion should be called with success. Got \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testRefreshCredentialsStuckInAwaiting() {
        let initialStatus = Credentials.Status.awaitingSupplementalInformation([Provider.Field(description: "Code", hint: "", maxLength: nil, minLength: nil, isMasked: false, isNumeric: false, isImmutable: false, isOptional: false, name: "code", initialValue: "", pattern: "", patternError: "", helpText: "", selectOptions: [])])

        let credentials = Credentials.makeTestCredentials(providerName: "test", kind: .keyfob, status: initialStatus)

        let service = MutableCredentialsService(credentialsList: [credentials])

        service.credentialsStatusAfterRefresh = initialStatus
        service.credentialsStatusAfterSupplementalInformation = .updated

        let context = CredentialsContext(tink: .shared, credentialsService: service)
        context.pollingStrategy = .constant(.leastNonzeroMagnitude)

        let completionCalled = expectation(description: "Refresh credentials completion should be called with success")
        let awaitingSupplementalInfoCalled = expectation(description: "Awaiting supplemental task status callback called")

        task = context.refresh(credentials) { status in
            switch status {
            case .awaitingSupplementalInformation(let task):
                awaitingSupplementalInfoCalled.fulfill()
                var form = Form(supplementInformationTask: task)
                form.fields[0].text = "test"
                task.submit(form)
            default:
                XCTFail()
            }
        } completion: { result in
            do {
                _ = try result.get()
                completionCalled.fulfill()
            } catch {
                XCTFail("Completion should be called with success. Got \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testAddingCredentialsWithoutRetainingTask() {
        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: mockedSuccessCredentialsService)

        let addCredentialsCompletionCalled = expectation(description: "add credentials completion should be called")
        let statusChangedToCreated = expectation(description: "add credentials status should be changed to created")
        let statusChangedToUpdating = expectation(description: "add credentials status should be changed to updating")

        let completionPredicate = AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false)

        credentialsContextUnderTest.add(for: Provider.nordeaPassword, form: Form(provider: Provider.nordeaPassword), completionPredicate: completionPredicate, authenticationHandler: { task in
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

    func testUpdatingCreatedCredentialsWithError() {
        let credentialsCreated = expectation(description: "credentials created with error")
        let addCredentialsFailed = expectation(description: "add credentials should fail because of wrong fields")

        let credentialsService = MockedCreatedCredentialsWithErrorService()

        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: credentialsService)
        credentialsContextUnderTest.pollingStrategy = .constant(.leastNonzeroMagnitude)

        var form = Form(provider: Provider.testPassword)
        form.fields[name: "username"]?.text = "tonk"

        credentialsContextUnderTest.add(for: Provider.testPassword, form: form, authenticationHandler: { task in
        }, progressHandler: { status in
            switch status {
            case .created:
                credentialsCreated.fulfill()
            case .authenticating:
                XCTFail("Something went wrong")
            case .updating:
                XCTFail("Something went wrong")
            }
        }, completion: { result in
            switch result {
            case .failure:
                addCredentialsFailed.fulfill()
            case .success:
                XCTFail("Something went wrong. Credentials should not have succeeded.")
            }
        })

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
        let credentialsIsUpdated = expectation(description: "already created credentials with error is successfully updated")

        form.fields[name: "username"]?.text = "tink"
        credentialsContextUnderTest.add(for: Provider.testPassword, form: form, authenticationHandler: { task in
        }, completion: { _ in
            credentialsIsUpdated.fulfill()
        })
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            } else {
                XCTAssertTrue(credentialsService.updateIsCalled)
            }
        }
    }

    func testRefreshingAlreadyCreatedCredentials() {
        let credentialsCreated = expectation(description: "credentials created with error")
        let addCredentialsFailed = expectation(description: "add credentials should fail because of wrong fields")

        let credentialsService = MockedCreatedCredentialsAwaithingThirdPartyService()

        let credentialsContextUnderTest = CredentialsContext(tink: .shared, credentialsService: credentialsService)
        credentialsContextUnderTest.pollingStrategy = .constant(.leastNonzeroMagnitude)

        credentialsContextUnderTest.add(for: Provider.testThirdPartyAuthentication, form: Form(provider: Provider.testThirdPartyAuthentication), authenticationHandler: { task in
        }, progressHandler: { status in
            switch status {
            case .created:
                credentialsCreated.fulfill()
            case .authenticating:
                XCTFail("Something went wrong")
            case .updating:
                XCTFail("Something went wrong")
            }
        }, completion: { result in
            switch result {
            case .failure:
                addCredentialsFailed.fulfill()
            case .success:
                XCTFail("Something went wrong. Credentials should not have succeeded.")
            }
        })

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
        let credentialsIsRefreshed = expectation(description: "already created credentials is successfully refreshed")

        credentialsContextUnderTest.add(for: Provider.testThirdPartyAuthentication, form: Form(provider: Provider.testThirdPartyAuthentication), authenticationHandler: { task in
        }, completion: { _ in
            credentialsIsRefreshed.fulfill()
        })

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            } else {
                XCTAssertTrue(credentialsService.refreshIsCalled)
            }
        }
    }
}
