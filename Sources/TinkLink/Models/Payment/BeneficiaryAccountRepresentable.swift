/// A transfer beneficiary is a transfer destination account.
public protocol BeneficiaryAccountRepresentable {
    /// The type of the `accountNumber` that this beneficiary has.
    var accountNumberKind: AccountNumberKind { get }
    /// The account number for the beneficiary. The structure of this field depends on the `accountNumberKind`.
    var accountNumber: String { get }
}
