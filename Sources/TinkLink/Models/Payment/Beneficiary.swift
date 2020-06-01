import Foundation

/// A beneficiary is a payment or transfer destination account which has been authorized by the bank.
///
/// Each beneficiary belongs to an account, which means that the given account can send money to that beneficiary.
/// - Note: Different banks treat beneficiaries in different ways. Some treat them as fully trusted, meaning no signing at all is required when transferring money to the beneficiary. Other banks treat them more as address books of registered recipients
public struct Beneficiary: Equatable {
    /// The type of the accountNumber that this beneficiary has.
    public let accountNumberKind: String
    /// The name chosen by the user for this beneficiary.
    public let name: String?
    /// The identifier of the account that this beneficiary belongs to.
    public let ownerAccountID: Account.ID
    /// The account number for the beneficiary. The structure of this field depends on the type.
    public let accountNumber: String?
}
