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
        guard let uri = URL(string: "\(kind.value)://\(accountNumber)") else { return nil }

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
