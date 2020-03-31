import Foundation

/// A user in the Tink API.
public struct User {
    public let accessToken: AccessToken
    let userProfile: UserProfile?

    public var username: String? {
        return userProfile?.username
    }

    init(accessToken: AccessToken, userProfile: UserProfile? = nil) {
        self.accessToken = accessToken
        self.userProfile = userProfile
    }
}
