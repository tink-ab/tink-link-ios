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
        XCTAssertEqual(context.termsAndConditions(), URL(string: "https://link.tink.com/terms-and-conditions/en?locale=en_US&chromeless=true"))
    }

    func testPrivacyPolicyLink() {
        XCTAssertEqual(context.privacyPolicy(), URL(string: "https://link.tink.com/privacy-policy/en?locale=en_US&chromeless=true"))
    }

    func testPrivacyTermsAndConditionForDifferentLanguages() {
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "sv_SE")), URL(string: "https://link.tink.com/terms-and-conditions/sv?locale=sv_SE&chromeless=true"))
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "fi_FI")), URL(string: "https://link.tink.com/terms-and-conditions/fi?locale=fi_FI&chromeless=true"))
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "de_DE")), URL(string: "https://link.tink.com/terms-and-conditions/de?locale=de_DE&chromeless=true"))
        XCTAssertEqual(context.termsAndConditions(for: Locale(identifier: "zh-Hant-HK")), URL(string: "https://link.tink.com/terms-and-conditions/zh?locale=zh-Hant-HK&chromeless=true"))
    }

    func testPrivacyPolicyLinkForDifferentLanguages() {
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "sv_SE")), URL(string: "https://link.tink.com/privacy-policy/sv?locale=sv_SE&chromeless=true"))
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "fi_FI")), URL(string: "https://link.tink.com/privacy-policy/fi?locale=fi_FI&chromeless=true"))
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "de_DE")), URL(string: "https://link.tink.com/privacy-policy/de?locale=de_DE&chromeless=true"))
        XCTAssertEqual(context.privacyPolicy(for: Locale(identifier: "zh-Hant-HK")), URL(string: "https://link.tink.com/privacy-policy/zh?locale=zh-Hant-HK&chromeless=true"))
    }
}
