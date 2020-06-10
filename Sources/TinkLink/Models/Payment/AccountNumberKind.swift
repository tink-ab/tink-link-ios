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

    /// An IBAN account number type.
    public static let iban: Self = "iban"
    /// A Swedish account number type.
    public static let se: Self = "se"
    /// A Swedish Bankgiro account number type.
    public static let seBankGiro: Self = "se-bg"
    /// A Swedish PlusGiro account number type.
    public static let sePlusGiro: Self = "se-pg"
    /// A sort code account number type.
    public static let sortCode: Self = "sort-code"
}
