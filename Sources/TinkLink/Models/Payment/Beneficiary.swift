import Foundation

public struct Beneficiary: Equatable {
    public let name: String?
    public let accountID: Account.ID
    public let accountNumber: String?

    let uri: URL?
}
