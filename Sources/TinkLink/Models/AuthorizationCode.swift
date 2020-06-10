/// An authorization code from the Tink backend.
public struct AuthorizationCode: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init(_ value: String) {
        self.rawValue = value
    }
}
