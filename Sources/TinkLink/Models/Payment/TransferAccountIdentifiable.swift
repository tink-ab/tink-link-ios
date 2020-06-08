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

extension Beneficiary: TransferAccountIdentifiable {
    public var transferAccountID: String {
        var urlComponents = URLComponents()
        urlComponents.scheme = accountNumberKind.value
        urlComponents.host = accountNumber
        return urlComponents.url?.absoluteString ?? "\(accountNumberKind.value)://\(accountNumber)"
    }
}

extension BeneficiaryAccount: TransferAccountIdentifiable {
    public var transferAccountID: String {
        var urlComponents = URLComponents()
        urlComponents.scheme = accountNumberKind.value
        urlComponents.host = accountNumber
        return urlComponents.url?.absoluteString ?? "\(accountNumberKind.value)://\(accountNumber)"
    }
}
