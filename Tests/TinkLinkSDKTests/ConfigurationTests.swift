@testable import TinkLinkSDK
import XCTest

class ConfigurationTests: XCTestCase {
    func testConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = try! TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI, environment: .production)
        let link = TinkLink(configuration: configuration)
        XCTAssertNotNil(link.configuration)
    }

    func testConfigureTinkLinkWithConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = try! TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI, environment: .production)
        let link = TinkLink(configuration: configuration)
        XCTAssertEqual(link.configuration.redirectURI, URL(string: "http://my-customer-app.com/authentication")!)
    }

    func testConfigureWithoutRedirectURLHost() {
        let redirectURI = URL(string: "http-my-customer-app://")!
        do {
            let _ = try TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI, environment: .production)
            XCTFail("Cannot configure TinkLink with redriect url without host")
        } catch let urlError as URLError {
            XCTAssert(urlError.code == .cannotFindHost)
        } catch {
            XCTFail("Cannot configure TinkLink with redriect url without host")
        }
    }

    func testConfigureSharedTinkLinkWithConfigurationWithAppURI() {
        TinkLink._shared = nil
        let redirectURI = URL(string: "my-customer-app://authentication")!
        let configuration = try! TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI, environment: .production)
        TinkLink.configure(with: configuration)
        XCTAssertEqual(TinkLink.shared.configuration.redirectURI, redirectURI)
    }
}
