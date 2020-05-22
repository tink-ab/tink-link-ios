import Foundation

/// A TransferEntityURIrepresents the URI for making or reciving transfers.
/// A TransferEntityURIrepresents is composed with two parts, A kind with value of `iban`, `sepa-eur` etc. And an account number.
public struct TransferEntityURI {
    public struct Kind: ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

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
    init?(account: Account) {
        guard let uri = account.transferSourceIdentifiers?.first else { return  nil }

        self.init(uri: uri)
    }
}

extension TransferEntityURI {
    init?(beneficiary: Beneficiary) {
        guard let uri = beneficiary.uri else { return  nil }

        self.init(uri: uri)
    }
}
