import XCTest
@testable import TinkLink

class UserContextTest: XCTestCase {
    var mockedSuccessOAuthService: MockedSuccessOAuthService!
    var mockedInvalidArgumentFailurefulOAuthService: MockedInvalidArgumentFailurefulOAuthService!
    var mockedUnauthenticatedErrorOAuthService: MockedUnauthenticatedErrorOAuthService!
    var mockedUserService: MockedUserService!


    override func setUp() {
        mockedSuccessOAuthService = MockedSuccessOAuthService()
        mockedInvalidArgumentFailurefulOAuthService = MockedInvalidArgumentFailurefulOAuthService()
        mockedUnauthenticatedErrorOAuthService = MockedUnauthenticatedErrorOAuthService()
        mockedUserService = MockedUserService()
    }

    func testSuccessfulWhenCreateAnonymousUser() {
        let completionCalled = expectation(description: "completion should be called")

        let userContext = UserContext(oAuthService: mockedSuccessOAuthService, userService: mockedUserService)
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

        let userContext = UserContext(oAuthService: mockedInvalidArgumentFailurefulOAuthService, userService: mockedUserService)
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

        let userContext = UserContext(oAuthService: mockedUnauthenticatedErrorOAuthService, userService: mockedUserService)
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
