import Foundation

/// A credential to use with the TinkPFM object.
public enum SessionCredential {
    /// A session token.
    case sessionID(String)
    /// An OAuth access token.
    case accessToken(String)
}
