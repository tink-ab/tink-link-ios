/// A type representing an kind of account number.
public struct AccountNumberKind: Hashable, ExpressibleByStringLiteral {
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

    public static let iban: Self = "iban"
    public static let se: Self = "se"
    public static let seBankGiro: Self = "se-bg"
    public static let sePlusGiro: Self = "se-pg"
    public static let sortCode: Self = "sort-code"
}
