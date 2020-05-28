import Foundation

/// A beneficiary is a payment or transfer destination account.
public struct Beneficiary: Equatable {
    /// The type of the accountNumber that this beneficiary has.
    public let accountNumberType: String
    /// The name chosen by the user for this beneficiary.
    public let name: String?
    /// The identifier of the account that this beneficiary belongs to.
    public let ownerAccountID: Account.ID
    /// The account number for the beneficiary. The structure of this field depends on the type.
    public let accountNumber: String?

    let uri: URL?
}
