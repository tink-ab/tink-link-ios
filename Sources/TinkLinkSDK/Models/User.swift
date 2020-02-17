import Foundation

/// A user in the Tink API.
public struct User {
    let accessToken: AccessToken
    public let userProfile: UserProfile?

    init(accessToken: AccessToken, userProfile: UserProfile? = nil) {
        self.accessToken = accessToken
        self.userProfile = userProfile
    }
}
