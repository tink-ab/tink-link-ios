import Foundation

/// A type that provides values for an account number.
public protocol TransferAccountNumberRepresentable {
    /// The kind of the `accountNumber`.
    var accountNumberKind: AccountNumberKind { get }
    /// The account number.
    /// - Note: The structure of this value depends on the `accountNumberKind`.
    var accountNumber: String { get }
}

extension TransferAccountNumberRepresentable {
    var uri: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = accountNumberKind.value
        urlComponents.host = accountNumber
        return urlComponents.url
    }
}

extension Account: TransferAccountNumberRepresentable {
    public var accountNumberKind: AccountNumberKind {
        let kind = transferSourceIdentifiers?.first?.scheme ?? "tink"
        return AccountNumberKind(kind)
    }
}
