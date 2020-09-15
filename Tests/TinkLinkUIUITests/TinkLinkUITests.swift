import XCTest

class TinkLinkUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false

        app.launchEnvironment = ["TINK_LINK_UI_TESTS_HOST_CLIENT_ID": ""]
    }

    func testUnauthenticatedAlert() {
        app.launchEnvironment["TINK_LINK_UI_TESTS_HOST_CLIENT_ID"] = nil

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

    func testAddingTestBankIDCredentials() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.staticTexts["Test BankID"].waitForExistence(timeout: 3))
        tablesQuery.staticTexts["Test BankID"].tap()
        tablesQuery.staticTexts["Test BankID (successful)"].tap()
        let numberField = tablesQuery.textFields["Social security number"]
        numberField.tap()
        numberField.typeText("180012121212")

        app.buttons["Open BankID"].tap()
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 30))
        app.buttons["Done"].tap()

        XCTAssertTrue(getStartedButton.isHittable)
    }
}
