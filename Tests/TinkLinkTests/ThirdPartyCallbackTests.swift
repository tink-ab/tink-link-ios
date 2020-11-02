@testable import TinkLink
import XCTest

class ThirdPartyCallbackTests: XCTestCase {
    func testValidCallbackURL() {
        var appURI = Tink.shared.configuration.appURI
        appURI?.appendPathComponent("someValue")
        XCTAssertNotNil(appURI)
        XCTAssert(Tink.shared.open(appURI!))
    }

    func testInvalidCallbackURL() {
        if let scheme = Tink.shared.configuration.appURI?.scheme, let url = URL(string: "\(scheme)://randomHost/randomPath") {
            XCTAssert(!Tink.shared.open(url))
        }
    }
}
