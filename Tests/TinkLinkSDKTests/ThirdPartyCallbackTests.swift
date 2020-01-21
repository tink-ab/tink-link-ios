import XCTest
@testable import TinkLinkSDK

class ThirdPartyCallbackTests: XCTestCase {
    func testValidCallbackURL() {
        var redirectURI = TinkLink.shared.configuration.redirectURI
        redirectURI.appendPathComponent("someValue")
        XCTAssert(TinkLink.shared.open(redirectURI))
    }

    func testInvalidCallbackURL() {
        if let scheme = TinkLink.shared.configuration.redirectURI.scheme, let url = URL(string: "\(scheme)://randomHost/randomPath") {
            XCTAssert(!TinkLink.shared.open(url))
        }
    }
}
