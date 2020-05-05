import Foundation

@available(*, deprecated, renamed: "UserSession")
public typealias SessionCredential = UserSession

/// A user session to use with the Tink object.
public enum UserSession {
    /// A session token.
    case sessionID(String)
    /// An OAuth access token.
    case accessToken(String)
}
