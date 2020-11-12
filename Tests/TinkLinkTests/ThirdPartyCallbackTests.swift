@testable import TinkLink
import XCTest

class ThirdPartyCallbackTests: XCTestCase {
    override class func setUp() {
        Tink.configure(with: Tink.Configuration(clientID: "testID", appURI: URL(string: "app://callback")!))
        // Has to access credentials context before open method can be used successfully.
        _ = Tink.shared.credentialsContext
    }

    func testValidCallbackURL() {
        let redirectURI = URL(string: "app://callback/someValue?state=1234")!
        XCTAssert(Tink.shared.open(redirectURI))
    }

    func testInvalidCallbackURL() {
        if let scheme = Tink.shared.configuration.appURI!.scheme, let url = URL(string: "\(scheme)://randomHost/randomPath") {
            XCTAssert(!Tink.shared.open(url))
        }
    }
}
