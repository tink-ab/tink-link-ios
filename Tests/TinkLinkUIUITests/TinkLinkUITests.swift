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

        let alert = app.alerts["Something went wrong. Please try again later."]
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
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        numberField.typeText("180012121212")

        app.buttons["Open BankID"].tap()

        let waitingStatusText = app.staticTexts["Waiting for authentication on another device"]
        XCTAssertTrue(waitingStatusText.waitForExistence(timeout: 20))

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
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        usernameField.typeText("tink")

        let passwordField = tablesQuery.secureTextFields["Password"]
        passwordField.tap()
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        passwordField.typeText("tink-1234")

        app.buttons["Log in"].firstMatch.tap()

        let statusText = app.staticTexts["Connecting to Test Password, please wait…"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 10))

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 1))
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
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        usernameField.typeText("tink-test")

        app.buttons["Log in"].firstMatch.tap()

        let supplementalInformationNavigationBar = app.navigationBars["Supplemental information"]
        XCTAssertTrue(supplementalInformationNavigationBar.waitForExistence(timeout: 5))

        let inputCodeField = app.tables.textFields["Input Code"]
        XCTAssert(inputCodeField.waitForExistence(timeout: 5))
        inputCodeField.tap()
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        inputCodeField.typeText("1234")

        XCTAssertTrue(supplementalInformationNavigationBar.waitForExistence(timeout: 5))

        let submitButton = app.buttons["Submit"]
        submitButton.tap()

        let sendingStatusText = app.staticTexts["Sending…"]
        XCTAssertTrue(sendingStatusText.waitForExistence(timeout: 5))

        XCTAssertTrue(supplementalInformationNavigationBar.waitForExistence(timeout: 5))

        XCTAssert(inputCodeField.waitForExistence(timeout: 5))
        inputCodeField.tap()
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        inputCodeField.typeText("4321")

        submitButton.tap()

        XCTAssertTrue(sendingStatusText.waitForExistence(timeout: 5))

        let connectingStatusText = app.staticTexts["Connecting to Test Multi-Supplemental, please wait…"]
        XCTAssertTrue(connectingStatusText.waitForExistence(timeout: 10))

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 1))
        XCTAssertTrue(getStartedButton.isHittable)
    }

    func testSearch() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let chooseBankNavigationBar = app.navigationBars["Choose your bank"]
        XCTAssertTrue(chooseBankNavigationBar.waitForExistence(timeout: 10))

        let searchField = app.searchFields["Search for a bank or card"]
        XCTAssert(searchField.waitForExistence(timeout: 5))
        searchField.tap()

        let qrCodeProviderCell = app.tables["Search results"].staticTexts["Test BankID with QR code (successful)"]
        XCTAssertFalse(qrCodeProviderCell.exists)

        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        searchField.typeText("Test")

        XCTAssertTrue(qrCodeProviderCell.exists)
        XCTAssertTrue(qrCodeProviderCell.isHittable)
        qrCodeProviderCell.tap()

        let tablesQuery = app.tables
        let textField = tablesQuery.textFields["Social security number"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        app.navigationBars.buttons["Cancel"].tap()

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 1))
        XCTAssertTrue(getStartedButton.isHittable)
    }

    func testWrongInput() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let tablesQuery = app.tables
        let bankIDCell = tablesQuery.cells.staticTexts["Test BankID"]
        XCTAssertTrue(bankIDCell.waitForExistence(timeout: 3))
        bankIDCell.tap()
        tablesQuery.cells.staticTexts["Test BankID (successful)"].tap()

        let inputField = tablesQuery.textFields["Social security number"]
        XCTAssertTrue(inputField.waitForExistence(timeout: 2))
        inputField.tap()

        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))

        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()

        let openBankIDButton = app.buttons["Open BankID"]
        XCTAssertTrue(openBankIDButton.waitForExistence(timeout: 2))
        openBankIDButton.tap()

        XCTAssertTrue(tablesQuery.staticTexts["This field must be at least 12 characters."].exists)
    }

    func testCancel() {
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
        XCTAssert(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("tink-1234")

        app.buttons["Log in"].firstMatch.tap()

        let statusText = app.staticTexts["Connecting to Test Password, please wait…"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 10))
        app.buttons["Cancel"].firstMatch.tap()

        let cancelButton = app.buttons["Yes, cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.firstMatch.tap()

        XCTAssertTrue(app.buttons["Log in"].waitForExistence(timeout: 10))

        XCTAssertFalse(statusText.exists)
    }

    func testProviderTreeGrouping() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let tablesQuery = app.tables

        let providerCell = tablesQuery.cells.staticTexts["Nordea"]
        XCTAssert(providerCell.waitForExistence(timeout: 5))
        providerCell.tap()
        tablesQuery.staticTexts["Personal"].tap()
        tablesQuery.staticTexts["Mortgage Aggregation, Checking Accounts, Savings Accounts, Credit Cards, Investments, Loans & Identity Data"].tap()

        let numberField = tablesQuery.textFields["Social security number"]
        XCTAssertTrue(numberField.waitForExistence(timeout: 5))
    }

    func testShowingPrivacyPolicy() {
        app.launch()

        app.buttons["Get Started"].tap()

        let passwordProviderCell = app.tables.cells.staticTexts["Test Password"]
        XCTAssertTrue(passwordProviderCell.waitForExistence(timeout: 5))
        passwordProviderCell.tap()

        let textView = app.textViews.element(matching: .textView, identifier: "termsAndConsentText")
        XCTAssertTrue(textView.waitForExistence(timeout: 2))

        let privacyPolicyLink = textView.links["Privacy Policy"]
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 5))
        XCTAssertTrue(privacyPolicyLink.isHittable)
        privacyPolicyLink.tap()

        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 15))

        XCTAssertFalse(privacyPolicyLink.isHittable)
    }

    func testShowingConsentDetails() {
        app.launch()

        app.buttons["Get Started"].tap()

        let passwordProviderCell = app.tables.cells.staticTexts["Test Password"]
        XCTAssertTrue(passwordProviderCell.waitForExistence(timeout: 5))
        passwordProviderCell.tap()

        let textView = app.textViews.element(matching: .textView, identifier: "termsAndConsentText")
        XCTAssert(textView.waitForExistence(timeout: 2))

        let viewDetailsLink = textView.links["View details"]
        XCTAssertTrue(viewDetailsLink.waitForExistence(timeout: 5))
        XCTAssertTrue(viewDetailsLink.isHittable)
        viewDetailsLink.tap()

        XCTAssertTrue(app.tables.staticTexts["By following through this service, we'll collect financial data from you. These are the data points we will collect from you"].waitForExistence(timeout: 5))
        XCTAssertFalse(viewDetailsLink.isHittable)
        app.navigationBars["TinkLinkUI.ScopeDescriptionListView"].buttons["Close"].tap()

        XCTAssertTrue(viewDetailsLink.isHittable)
    }

    func testAddingTestFailingBankIDCredentials() {
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()

        let tablesQuery = app.tables
        let bankIDCell = tablesQuery.cells.staticTexts["Test BankID"]
        XCTAssertTrue(bankIDCell.waitForExistence(timeout: 3))
        bankIDCell.tap()
        tablesQuery.cells.staticTexts["Test BankID (failing) "].tap()
        let numberField = tablesQuery.textFields["Social security number"]
        XCTAssert(numberField.waitForExistence(timeout: 5))
        numberField.tap()
        XCTAssert(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        numberField.typeText("180012121212")

        app.buttons["Open BankID"].tap()

        let failedAlert = app.alerts.staticTexts["Authentication failed"]
        XCTAssertTrue(failedAlert.waitForExistence(timeout: 10))

        XCTAssertFalse(numberField.isHittable)

        let failedAlertOKButton = app.alerts.buttons["OK"]
        XCTAssertTrue(failedAlertOKButton.exists)
        failedAlertOKButton.tap()

        XCTAssertFalse(failedAlert.exists)
        XCTAssertTrue(numberField.isHittable)

        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        XCTAssertTrue(cancelButton.isHittable)
        cancelButton.tap()

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 5))
        XCTAssertTrue(getStartedButton.isHittable)
    }
}
