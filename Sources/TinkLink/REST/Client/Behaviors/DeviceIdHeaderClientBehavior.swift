import Foundation

struct DeviceIdHeaderClientBehavior: ClientBehavior {
    private let deviceId: String
    
    init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    var headers: [String: String] { ["X-Tink-Device-Id": deviceId] }
}
