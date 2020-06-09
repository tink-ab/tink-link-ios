/// An authorization code from the Tink backend.
public struct AuthorizationCode: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// Creates an authorization code.
    /// - Parameter value: The authorization code
    public init(_ value: String) {
        self.rawValue = value
    }
}
