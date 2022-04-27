import Foundation

/// `AuthenticationStrategy` represents the authentication strategy to use when authenticating the user towards Tink Link.
/// An access token would be used directly to initialize the user session.
/// An authorization code would be exchanged for an access token and then initialize the user session.
public enum AuthenticationStrategy {
    /// An OAuth access token.
    case accessToken(String)

    /// An authorization code that can be exchanged for an OAuth access token.
    case authorizationCode(String)
}
