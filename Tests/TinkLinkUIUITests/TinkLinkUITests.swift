import XCTest

class TinkLinkUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false

        app.launchEnvironment = [:]
    }

    func testUnauthenticatedAlert() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        XCTAssertFalse(getStartedButton.isHittable)

        let alert = app.alerts["Unauthenticated"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))

        alert.buttons["Dismiss"].tap()

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 1))

        XCTAssertTrue(getStartedButton.isHittable)
    }
}
