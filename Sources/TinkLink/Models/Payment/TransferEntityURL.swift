import Foundation

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

        if let uri = urlComponents.url {
            self.uri = uri
        } else {
            return nil
        }
    }

    init(uri: URL) {
        self.uri = uri
    }

    let uri: URL
}

extension TransferEntityURI {
    init?(account: Account) {
        if let uri = account.transferSourceIdentifiers?.first {
            self.uri = uri
        } else {
            return nil
        }
    }
}

extension TransferEntityURI {
    init?(beneficiary: Beneficiary) {
        if let uri = beneficiary.uri {
            self.uri = uri
        } else {
            return nil
        }
    }
}
