import Foundation

/// A user in the Tink API.
public struct User {
    /// A unique identifier of a `User`.
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

        public let value: String
    }

    let accessToken: AccessToken
    let userID: User.ID?
    let userProfile: UserProfile?

    /// The username of the current user.
    public var username: String? {
        return userProfile?.username
    }

    init(accessToken: AccessToken, userProfile: UserProfile? = nil, userID: User.ID? = nil) {
        self.accessToken = accessToken
        self.userProfile = userProfile
        self.userID = userID
    }
}
