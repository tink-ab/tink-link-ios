import Foundation

final class SDKHeaderClientBehavior: ClientBehavior {

    private let version: String?
    private let sdkName: String

    init(sdkName: String) {
        self.sdkName = sdkName
        self.version = Bundle(for: SDKHeaderClientBehavior.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var headers: [String: String] {
        var headers = ["X-Tink-SDK-Name": sdkName]
        headers["X-Tink-SDK-Version"] = version
        return headers
    }
}
