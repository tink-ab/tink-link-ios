import XCTest
@testable import TinkLinkSDK

class LinkTests: XCTestCase {
    let context = AuthorizationContext(
        tinkLink: TinkLink(
            configuration: try! .init(
                clientID: "abcdefgh",
                redirectURI: URL(string: "tink://test")!
            )
        ),
        user: User(accessToken: "12345678")
    )

    func testTermsAndConditionLink() {
        XCTAssertEqual(context.termsAndConditions(), URL(string: "https://link.tink.com/terms-and-conditions/en"))
    }

    func testPrivacyPolicyLink() {
        XCTAssertEqual(context.privacyPolicy(), URL(string: "https://link.tink.com/privacy-policy/en"))
    }
}
