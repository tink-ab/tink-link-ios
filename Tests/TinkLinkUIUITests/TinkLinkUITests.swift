import XCTest

class TinkLinkUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false

        app.launchEnvironment["TINK_LINK_UI_TESTS_HOST_CLIENT_ID"] = ProcessInfo.processInfo.environment["TINK_LINK_UI_TESTS_HOST_CLIENT_ID"]
    }

    func testUnauthenticatedAlert() {
        app.launchEnvironment["TINK_LINK_UI_TESTS_HOST_CLIENT_ID"] = nil

        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        XCTAssertFalse(getStartedButton.isHittable)

        let alert = app.alerts["Could not find the OAuth client"]
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
        let bankIDCell = tablesQuery.cells.staticTexts["Test BankID"]
        XCTAssertTrue(bankIDCell.waitForExistence(timeout: 3))
        bankIDCell.tap()
        tablesQuery.cells.staticTexts["Test BankID (successful)"].tap()
        let numberField = tablesQuery.textFields["Social security number"]
        XCTAssert(numberField.waitForExistence(timeout: 5))
        numberField.tap()
        numberField.typeText("180012121212")

        app.buttons["Open BankID"].tap()

        let waitingStatusText = app.staticTexts["Waiting for authentication on another device."]
        XCTAssertTrue(waitingStatusText.waitForExistence(timeout: 20))

        let statusText = app.staticTexts["Connecting to Test BankID (successful), please wait…"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 20))

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 20))
        doneButton.tap()

        XCTAssertTrue(getStartedButton.isHittable)
    }

    func testAddingTestPasswordCredentials() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let tablesQuery = app.tables

        let passwordProviderCell = tablesQuery.cells.staticTexts["Test Password"]

        XCTAssertTrue(passwordProviderCell.waitForExistence(timeout: 5))
        passwordProviderCell.tap()

        let usernameField = tablesQuery.textFields["Username"]
        XCTAssert(usernameField.waitForExistence(timeout: 5))
        usernameField.tap()
        usernameField.typeText("tink")

        let passwordField = tablesQuery.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("tink-1234")

        app.buttons["Continue"].firstMatch.tap()

        let statusText = app.staticTexts["Connecting to Test Password, please wait…"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 10))

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()

        XCTAssertTrue(getStartedButton.isHittable)
    }

    func testAddingTestMultiSupplementalProvider() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let tablesQuery = app.tables

        let multiSupplementalCell = tablesQuery.cells.staticTexts["Test Multi-Supplemental"]
        XCTAssert(multiSupplementalCell.waitForExistence(timeout: 5))
        multiSupplementalCell.tap()

        let usernameField = tablesQuery.textFields["Username"]
        XCTAssert(usernameField.waitForExistence(timeout: 5))
        usernameField.tap()
        usernameField.typeText("tink-test")

        app.buttons["Continue"].firstMatch.tap()

        let supplementalInformationNavigationBar = app.navigationBars["Supplemental information"]
        XCTAssertTrue(supplementalInformationNavigationBar.waitForExistence(timeout: 5))

        let inputCodeField = app.tables.textFields["Input Code"]
        XCTAssert(inputCodeField.waitForExistence(timeout: 5))
        inputCodeField.tap()
        inputCodeField.typeText("1234")

        XCTAssertTrue(supplementalInformationNavigationBar.waitForExistence(timeout: 5))

        let submitButton = app.buttons["Submit"]
        submitButton.tap()

        let sendingStatusText = app.staticTexts["Sending…"]
        XCTAssertTrue(sendingStatusText.waitForExistence(timeout: 5))

        XCTAssertTrue(supplementalInformationNavigationBar.waitForExistence(timeout: 5))

        XCTAssert(inputCodeField.waitForExistence(timeout: 5))
        inputCodeField.tap()
        inputCodeField.typeText("4321")

        submitButton.tap()

        XCTAssertTrue(sendingStatusText.waitForExistence(timeout: 5))

        let connectingStatusText = app.staticTexts["Connecting to Test Multi-Supplemental, please wait…"]
        XCTAssertTrue(connectingStatusText.waitForExistence(timeout: 10))

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()

        XCTAssertTrue(getStartedButton.isHittable)
    }

    func testSearch() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let chooseBankNavigationBar = app.navigationBars["Choose bank"]
        XCTAssertTrue(chooseBankNavigationBar.waitForExistence(timeout: 10))

        let searchField = app.searchFields["Search for a bank or card"]
        XCTAssert(searchField.waitForExistence(timeout: 5))
        searchField.tap()

        let qrCodeProviderCell = app.tables["Search results"].staticTexts["Test BankID with QR code (successful)"]
        XCTAssertFalse(qrCodeProviderCell.exists)

        searchField.typeText("Test")

        XCTAssertTrue(qrCodeProviderCell.exists)
        XCTAssertTrue(qrCodeProviderCell.isHittable)
        qrCodeProviderCell.tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["Test BankID with QR code (successful)"].firstMatch.tap()
        XCTAssertTrue(tablesQuery.textFields["Social security number"].exists)
        app.navigationBars["Authentication"].buttons["Cancel"].tap()

        XCTAssertTrue(getStartedButton.isHittable)
    }
}
