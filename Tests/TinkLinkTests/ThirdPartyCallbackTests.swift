@testable import TinkLink
import XCTest

class ThirdPartyCallbackTests: XCTestCase {
    func testValidCallbackURL() {
        var redirectURI = Tink.shared.configuration.redirectURI
        redirectURI.appendPathComponent("someValue")
        XCTAssert(Tink.shared.open(redirectURI))
    }

    func testInvalidCallbackURL() {
        if let scheme = Tink.shared.configuration.redirectURI.scheme, let url = URL(string: "\(scheme)://randomHost/randomPath") {
            XCTAssert(!Tink.shared.open(url))
        }
    }
}
