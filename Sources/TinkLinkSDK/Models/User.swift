import Foundation

/// A user in the Tink API.
public struct User {
    let accessToken: AccessToken
}

extension User {
    init(accessToken: String) {
        self.accessToken = AccessToken(accessToken)
    }
}
