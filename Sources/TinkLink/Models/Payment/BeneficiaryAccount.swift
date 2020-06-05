/// A beneficiary account is a payment or transfer destination account.
public struct BeneficiaryAccount: BeneficiaryAccountRepresentable {
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

    static func iban(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .iban, accountNumber: accountNumber)
    }

    static func se(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .se, accountNumber: accountNumber)
    }

    static func seBankGiro(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .seBankGiro, accountNumber: accountNumber)
    }

    static func sePlusGiro(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .sePlusGiro, accountNumber: accountNumber)
    }

    static func sortCode(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .sortCode, accountNumber: accountNumber)
    }
}
