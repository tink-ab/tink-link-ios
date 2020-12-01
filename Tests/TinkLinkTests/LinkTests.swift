import XCTest
@testable import TinkLink

class LinkTests: XCTestCase {
    let context = ConsentContext(
        tink: Tink(
            configuration: TinkLinkConfiguration(
                clientID: "YOUR_CLIENT_ID",
                appURI: URL(string: "link-demo://tink")!
            )
        )
    )

    func testTermsAndConditionLink() {
        XCTAssertEqual(context.termsAndConditions(), URL(string: "https://link.tink.com/terms-and-conditions/en"))
    }

    func testPrivacyPolicyLink() {
        XCTAssertEqual(context.privacyPolicy(), URL(string: "https://link.tink.com/privacy-policy/en"))
    }

    func testPrivacyTermsAndConditionForDifferentLanguages() {
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "sv_SE")), URL(string: "https://link.tink.com/terms-and-conditions/sv"))
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "fi_FI")), URL(string: "https://link.tink.com/terms-and-conditions/fi"))
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "de_DE")), URL(string: "https://link.tink.com/terms-and-conditions/de"))
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "zh-Hant-HK")), URL(string: "https://link.tink.com/terms-and-conditions/zh"))
    }

    func testPrivacyPolicyLinkForDifferentLanguages() {
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "sv_SE")), URL(string: "https://link.tink.com/privacy-policy/sv"))
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "fi_FI")), URL(string: "https://link.tink.com/privacy-policy/fi"))
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "de_DE")), URL(string: "https://link.tink.com/privacy-policy/de"))
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "zh-Hant-HK")), URL(string: "https://link.tink.com/privacy-policy/zh"))
    }
}
