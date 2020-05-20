import Foundation

public struct Beneficiary: Equatable {
    public let name: String?
    public let accountID: Account.ID
    public let accountNumber: String?

    let uri: URL?
}

extension Beneficiary {
    init(account: Account, transferDestination: TransferDestination) {
        self.name = transferDestination.name
        self.accountID = account.id
        self.accountNumber = transferDestination.displayAccountNumber
        self.uri = transferDestination.uri
    }
}
