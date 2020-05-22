import Foundation

/// A beneficiary is a payment or transfer destination account.
public struct Beneficiary: Equatable {
    /// The beneficiary type
    public let type: String
    /// The beneficiary name
    public let name: String?
    /// Account ID that's associated with this beneficiary.
    public let accountID: Account.ID
    /// Account number that's associated with this beneficiary.
    public let accountNumber: String?

    let uri: URL?
}
