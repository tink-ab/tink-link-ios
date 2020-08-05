import Foundation

/// A type that can be used as an to or from account when initiating a transfer.
public protocol TransferAccountIdentifiable {
    /// The identity of the account.
    var transferAccountID: String { get }
}

extension Account: TransferAccountIdentifiable {
    public var transferAccountID: String {
        transferSourceIdentifiers?.first?.absoluteString ?? "tink://\(id.value)"
    }
}

extension Account.URI: TransferAccountIdentifiable {
    public var transferAccountID: String { value }
}

extension Beneficiary: TransferAccountIdentifiable {
    public var transferAccountID: String {
        var urlComponents = URLComponents()
        urlComponents.scheme = accountNumberKind.value
        var items = accountNumber.components(separatedBy: "/")
        urlComponents.host = items.removeFirst()
        if !items.isEmpty {
            urlComponents.path = "/" + items.joined(separator: "/")
        }
        if !name.isEmpty {
            urlComponents.queryItems = [URLQueryItem(name: "name", value: name)]
        }
        return urlComponents.url?.absoluteString ?? "\(accountNumberKind.value)://\(accountNumber)"
    }
}

extension BeneficiaryAccount: TransferAccountIdentifiable {
    public var transferAccountID: String {
        var urlComponents = URLComponents()
        urlComponents.scheme = accountNumberKind.value
        var items = accountNumber.components(separatedBy: "/")
        urlComponents.host = items.removeFirst()
        if !items.isEmpty {
            urlComponents.path = "/" + items.joined(separator: "/")
        }
        return urlComponents.url?.absoluteString ?? "\(accountNumberKind.value)://\(accountNumber)"
    }
}
