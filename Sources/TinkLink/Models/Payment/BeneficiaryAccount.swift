/// A beneficiary account is a payment or transfer destination account.
struct BeneficiaryAccount {
    /// The type of the accountNumber that this beneficiary has.
    public let accountNumberKind: AccountNumberKind
    /// The account number for the beneficiary. The structure of this field depends on the type.
    public let accountNumber: String
}
