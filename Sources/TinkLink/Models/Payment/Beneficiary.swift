import Foundation

/// A beneficiary is a payment or transfer destination account.
public struct Beneficiary: Equatable {
    /// beneficiary type
    public let type: String
    /// beneficiary name
    public let name: String?
    /// Account ID that linked to hte beneficiary
    public let accountID: Account.ID
    /// Account name that linked to hte beneficiary
    public let accountNumber: String?

    let uri: URL?
}
