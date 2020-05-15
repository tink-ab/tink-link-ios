import Foundation

public struct Beneficiary: Equatable, Identifiable {
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

        public let value: String
    }

    public let id: ID
    public let name: String?
    public let accountID: Account.ID
    public let accountNumber: String
    public let kind: String

    let uri: Transfer.TransferEntityURI?
}
