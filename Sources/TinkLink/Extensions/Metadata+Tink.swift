import Foundation
import GRPC

extension CallOptions {
    enum HeaderKey: String {
        case deviceID = "X-Tink-Device-ID"
        case authorization = "Authorization"
        case oauthClientID = "X-Tink-OAuth-Client-ID"
        case sdkName = "X-Tink-SDK-Name"
        case sdkVersion = "X-Tink-SDK-Version"

        var key: String {
            return rawValue.lowercased()
        }
    }

    mutating func add(key: String, value: String) {
        customMetadata.add(name: key, value: value)
    }

    mutating func addAccessToken(_ token: String? = nil) {
        if !hasAuthorization, let accessToken = token {
            add(key: HeaderKey.authorization.key, value: "Bearer \(accessToken)")
        }
    }

    var hasAuthorization: Bool {
        customMetadata[HeaderKey.authorization.key].isEmpty == false
    }
}
