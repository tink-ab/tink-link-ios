import XCTest

class TinkLinkUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false

        app.launchEnvironment = [:]
    }

    func testLaunch() {
        app.launch()
    }
}
