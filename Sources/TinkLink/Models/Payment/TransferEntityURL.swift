import Foundation

/// A TransferEntityURI represents the URI for making or reciving transfers.
/// A TransferEntityURI is composed with two parts, a kind with value of e.g. `iban` and an account number.
public struct TransferEntityURI {
    /// A type representing an kind of account URI.
    public struct Kind: ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        /// Creates a kind.
        /// - Parameter value: The `String` that represents the account kind.
        public init(_ value: String) {
            self.value = value
        }

        /// The `String` that represent the account kind.
        public let value: String
    }

    public init?(kind: Kind, accountNumber: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = kind.value
        urlComponents.host = accountNumber
        
        guard let uri = urlComponents.url else { return nil }

        self.init(uri: uri)
    }

    init(uri: URL) {
        self.uri = uri
    }

    let uri: URL
}

extension TransferEntityURI {
    public init?(account: Account) {
        guard let uri = account.transferSourceIdentifiers?.first else { return  nil }

        self.init(uri: uri)
    }
}

extension TransferEntityURI {
    public init?(beneficiary: Beneficiary) {
        guard let uri = beneficiary.uri else { return  nil }

        self.init(uri: uri)
    }
}
