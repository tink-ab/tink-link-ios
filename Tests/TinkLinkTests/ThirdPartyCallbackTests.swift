@testable import TinkLink
import XCTest

class ThirdPartyCallbackTests: XCTestCase {
    func testValidCallbackURL() {
        var redirectURI = Tink.shared.configuration.appURI!
        redirectURI.appendPathComponent("someValue")
        XCTAssert(Tink.shared.open(redirectURI))
    }

    func testInvalidCallbackURL() {
        if let scheme = Tink.shared.configuration.appURI!.scheme, let url = URL(string: "\(scheme)://randomHost/randomPath") {
            XCTAssert(!Tink.shared.open(url))
        }
    }
}
