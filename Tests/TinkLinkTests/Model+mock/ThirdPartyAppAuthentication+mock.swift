import Foundation
@testable import TinkCore

extension Credentials.ThirdPartyAppAuthentication {
    static func makeThirdPartyAppAuthentication(deepLinkURL: URL?) -> Self {
        Credentials.ThirdPartyAppAuthentication(
            downloadTitle: nil,
            downloadMessage: nil,
            upgradeTitle: nil,
            upgradeMessage: nil,
            appStoreURL: nil,
            scheme: nil,
            deepLinkURL: deepLinkURL
        )
    }
}
