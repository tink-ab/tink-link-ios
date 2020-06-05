/// A beneficiary account is a payment or transfer destination account.
public struct BeneficiaryAccount: BeneficiaryProtocol {
    /// The type of the `accountNumber` that this beneficiary has.
    public let accountNumberKind: AccountNumberKind
    /// The account number for the beneficiary. The structure of this field depends on the `accountNumberKind`.
    public let accountNumber: String

    /// Creates a beneficiary account.
    ///
    /// - Parameters:
    ///   - accountNumberKind: The type of the `accountNumber` that this beneficiary has.
    ///   - accountNumber: The account number for the beneficiary. The structure of this field depends on the `accountNumberKind`.
    public init(accountNumberKind: AccountNumberKind, accountNumber: String) {
        self.accountNumberKind = accountNumberKind
        self.accountNumber = accountNumber
    }
}
