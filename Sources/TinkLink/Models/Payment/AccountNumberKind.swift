/// A type representing an kind of account number.
public struct AccountNumberKind: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = value
    }

    /// Creates a kind.
    /// - Parameter value: The `String` that represents the account number kind.
    public init(_ value: String) {
        self.value = value
    }

    /// The `String` that represent the account number kind.
    public let value: String

    public static let iban: Kind = "iban"
    public static let se: Kind = "se"
    public static let seBankGiro: Kind = "se-bg"
    public static let sePlusGiro: Kind = "se-pg"
    public static let sortCode: Kind = "sort-code"
}
