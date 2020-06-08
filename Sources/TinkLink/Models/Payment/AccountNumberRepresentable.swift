/// A type that provides values for an account number.
public protocol AccountNumberRepresentable {
    /// The kind of the `accountNumber`.
    var accountNumberKind: AccountNumberKind { get }
    /// The account number.
    /// - Note: The structure of this value depends on the `accountNumberKind`.
    var accountNumber: String { get }
}
