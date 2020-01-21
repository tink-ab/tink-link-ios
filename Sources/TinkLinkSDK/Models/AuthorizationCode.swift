/// An authorization code from the Tink backend.
public struct AuthorizationCode: Hashable, RawRepresentable, Decodable {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ value: String) {
        self.rawValue = value
    }
}
