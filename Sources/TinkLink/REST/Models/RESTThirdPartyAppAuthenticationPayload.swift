import Foundation

struct RESTThirdPartyAppAuthenticationPayload: Codable {
    
    struct Ios: Codable {
        let appStoreUrl: URL?
        let scheme: String
        let deepLinkUrl: URL
    }

    let ios: Ios

    let downloadTitle: String?
    let downloadMessage: String?
    let upgradeTitle: String?
    let upgradeMessage: String?
}
