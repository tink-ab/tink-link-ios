import Foundation

final class SDKHeaderClientBehavior: ClientBehavior {
    private let version: String?

    init() {
        self.version = Bundle(for: SDKHeaderClientBehavior.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var headers: [String: String] {
        var headers = ["X-Tink-SDK-Name": "Tink PFM iOS"]
        headers["X-Tink-SDK-Version"] = version
        return headers
    }
}
