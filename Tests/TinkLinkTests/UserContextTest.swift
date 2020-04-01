import XCTest
@testable import TinkLink

class UserContextTest: XCTestCase {
    var mockedSuccessUserService: MockedSuccessUserService!
    var mockedInvalidArgumentFailurefulUserService: MockedInvalidArgumentFailurefulUserService!
    var mockedUnauthenticatedErrorUserService: MockedUnauthenticatedErrorUserService!
    var mockedAuthenticationService: MockedAuthenticationService!


    override func setUp() {
        mockedSuccessUserService = MockedSuccessUserService()
        mockedInvalidArgumentFailurefulUserService = MockedInvalidArgumentFailurefulUserService()
        mockedUnauthenticatedErrorUserService = MockedUnauthenticatedErrorUserService()
        mockedAuthenticationService = MockedAuthenticationService()
    }

    func testSuccessfulWhenCreateAnonymousUser() {
        let completionCalled = expectation(description: "completion should be called")

        let userContext = UserContext(userService: mockedSuccessUserService, authenticationService: mockedAuthenticationService)
        userContext.createTemporaryUser(for: "SE") { result in
            completionCalled.fulfill()
            do {
                _ = try result.get()
            } catch {
                XCTFail("Failed to get user with: \(error)")
            }
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testInvalidArgumentFailureWhenCreateAnonymousUser() {
        let completionCalled = expectation(description: "completion should be called")

        let userContext = UserContext(userService: mockedInvalidArgumentFailurefulUserService, authenticationService: mockedAuthenticationService)
        userContext.createTemporaryUser(for: "SE") { result in
            completionCalled.fulfill()
            do {
                _ = try result.get()
                XCTFail("Should fail to create the anonymous user")
            } catch {
                if case UserContext.Error.invalidMarketOrLocale = error {
                    return
                } else {
                    XCTFail("Should receive invalid market or locale error")
                }
            }
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }

    func testOtherErrorFailureWhenCreateAnonymousUser() {
        let completionCalled = expectation(description: "completion should be called")
        
        let userContext = UserContext(userService: mockedUnauthenticatedErrorUserService, authenticationService: mockedAuthenticationService)
        userContext.createTemporaryUser(for: "SE") { result in
            completionCalled.fulfill()
            do {
                _ = try result.get()
                XCTFail("Should fail to create the anonymous user")
            } catch {
                if case UserContext.Error.invalidMarketOrLocale = error {
                    XCTFail("Should not receive invalid market or locale error")
                } else if case ServiceError.unauthenticated = error {
                    return
                } else {
                    XCTFail("Should receive un-authenticated service error")
                }
            }
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations timeout with error: \(error)")
            }
        }
    }
}
