/// A beneficiary account is a payment or transfer destination account.
public struct BeneficiaryAccount {
    /// The kind of the `accountNumber` that this beneficiary has.
    public let accountNumberKind: AccountNumberKind
    /// The account number for the beneficiary.
    /// - Note: The structure of this value depends on the `accountNumberKind`.
    public let accountNumber: String

    /// Creates a beneficiary account.
    ///
    /// - Parameters:
    ///   - accountNumberKind: The kind of the account number.
    ///   - accountNumber: The account number for the beneficiary.
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

extension BeneficiaryAccount: TransferAccountNumberRepresentable {
    public var transferAccountNumberKind: AccountNumberKind { accountNumberKind }
    public var transferAccountNumber: String { accountNumber }
}
