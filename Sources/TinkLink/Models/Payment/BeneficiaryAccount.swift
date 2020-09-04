/// A beneficiary account is a payment or transfer destination account.
public struct BeneficiaryAccount {
    /// The kind of the `accountNumber` that this beneficiary has.
    public let accountNumberKind: AccountNumberKind
    /// The account number for the beneficiary.
    /// - Note: The structure of this value depends on the `accountNumberKind`.
    public let accountNumber: String
    /// The name of the beneficiary. Optional.
    public let name: String?

    /// Creates a beneficiary account.
    ///
    /// - Parameters:
    ///   - accountNumberKind: The kind of the account number.
    ///   - accountNumber: The account number for the beneficiary.
    ///   - name: The name of the beneficiary.
    public init(accountNumberKind: AccountNumberKind, accountNumber: String, name: String? = nil) {
        self.accountNumberKind = accountNumberKind
        self.accountNumber = accountNumber
        self.name = name
    }

    /// Creates a beneficiary account with an IBAN account number.
    /// - Parameter accountNumber: The account number for the beneficiary.
    /// - Returns: A beneficiary account.
    static func iban(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .iban, accountNumber: accountNumber)
    }

    /// Creates a beneficiary account with a Swedish account number.
    /// - Parameter accountNumber: The account number for the beneficiary.
    /// - Returns: A beneficiary account.
    static func se(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .se, accountNumber: accountNumber)
    }

    /// Creates a beneficiary account with a Swedish Bankgiro account number.
    /// - Parameter accountNumber: The account number for the beneficiary.
    /// - Returns: A beneficiary account.
    static func seBankGiro(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .seBankGiro, accountNumber: accountNumber)
    }

    /// Creates a beneficiary account with a Swedish PlusGiro account number.
    /// - Parameter accountNumber: The account number for the beneficiary.
    /// - Returns: A beneficiary account.
    static func sePlusGiro(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .sePlusGiro, accountNumber: accountNumber)
    }

    /// Creates a beneficiary account with a sort code account number.
    /// - Parameter accountNumber: The account number for the beneficiary.
    /// - Returns: A beneficiary account.
    static func sortCode(_ accountNumber: String) -> Self {
        return .init(accountNumberKind: .sortCode, accountNumber: accountNumber)
    }
}
