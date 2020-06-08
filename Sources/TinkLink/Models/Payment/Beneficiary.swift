import Foundation

/// A beneficiary is a payment or transfer destination account which has been authorized by the bank.
///
/// Each beneficiary belongs to an account, which means that the given account can send money to that beneficiary.
/// - Note: Different banks treat beneficiaries in different ways. Some treat them as fully trusted, meaning no signing at all is required when transferring money to the beneficiary. Other banks treat them more as address books of registered recipients
public struct Beneficiary: Equatable {
    /// The type of the `accountNumber` that this beneficiary has.
    @available(*, deprecated, renamed: "accountNumberKind")
    public var accountNumberType: String { accountNumberKind.value }
    /// The kind of the `accountNumber` that this beneficiary has.
    public let accountNumberKind: AccountNumberKind
    /// The account number for the beneficiary.
    /// - Note: The structure of this value depends on the `accountNumberKind`.
    public let accountNumber: String
    /// The name chosen by the user for this beneficiary.
    public let name: String
    /// The identifier of the account that this beneficiary belongs to.
    public let ownerAccountID: Account.ID
}
