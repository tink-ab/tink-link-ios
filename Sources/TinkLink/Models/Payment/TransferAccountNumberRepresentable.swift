import Foundation

/// A type that provides values for an account number.
public protocol TransferAccountNumberRepresentable {
    /// The kind of the `transferAccountNumber`.
    var transferAccountNumberKind: AccountNumberKind { get }
    /// The account number.
    /// - Note: The structure of this value depends on the `transferAccountNumberKind`.
    var transferAccountNumber: String { get }
}

extension TransferAccountNumberRepresentable {
    var uri: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = transferAccountNumberKind.value
        urlComponents.host = transferAccountNumber
        return urlComponents.url
    }
}

extension Account: TransferAccountNumberRepresentable {
    public var transferAccountNumberKind: AccountNumberKind {
        let kind = transferSourceIdentifiers?.first?.scheme ?? "tink"
        return AccountNumberKind(kind)
    }
    public var transferAccountNumber: String {
        return transferSourceIdentifiers?.first?.host ?? id.value
    }
}
