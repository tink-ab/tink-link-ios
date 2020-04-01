import Foundation

final class AuthorizationHeaderClientBehavior: ClientBehavior {

    var sessionCredential: SessionCredential?
    
    init(sessionCredential: SessionCredential?) {
        self.sessionCredential = sessionCredential
    }
    
    var headers: [String: String] {
        switch sessionCredential {
        case .sessionID(let sessionID):
            return ["Authorization": "Session \(sessionID)"]
        case .accessToken(let accessToken):
            return ["Authorization": "Bearer \(accessToken)"]
        default:
            return [:]
        }
    }
}
