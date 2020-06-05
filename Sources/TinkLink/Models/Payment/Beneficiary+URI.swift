import Foundation

extension Beneficiary {
    /// A type representing the URI for receiving transfers.
    ///
    /// A URI is composed with two parts, a kind with value of e.g. `iban` and an account number.
    public struct URI: Equatable, ExpressibleByStringLiteral {
        /// The `String` that represent the URI.
        public let value: String

        /// Creates a kind.
        /// - Parameter value: The `String` that represents the URI.
        public init(_ value: String) {
            self.value = value
        }

        public init(stringLiteral value: String) {
            self.value = value
        }
    }
}

extension Beneficiary.URI {
    /// A type representing an kind of account URI.
    @available(*, deprecated, renamed: "AccountNumberKind")
    public typealias Kind = AccountNumberKind
}

extension Beneficiary.URI {
    /// Creates a URI.
    ///
    /// Returns `nil` if a URI cannot be formed with the kind and account number (for example if the number contains characters that are illegal, or is an empty string).
    ///
    /// - Parameters:
    ///   - kind: The kind of account URI.
    ///   - accountNumber: The account number. The structure of this parameter depends on the `kind`.
    public init?(kind: AccountNumberKind, accountNumber: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = kind.value
        urlComponents.host = accountNumber

        guard let uri = urlComponents.url else { return nil }

        self.value = uri.absoluteString
    }
}

extension Beneficiary.URI {
    /// Creates a URI for a beneficiary.
    /// - Parameter beneficiary: The beneficiary.
    public init?(beneficiary: Beneficiary) {
        var urlComponents = URLComponents()
        urlComponents.scheme = beneficiary.accountNumberKind.value
        urlComponents.host = beneficiary.accountNumber
        if !beneficiary.name.isEmpty {
            urlComponents.queryItems = [URLQueryItem(name: "name", value: beneficiary.name)]
        }
        guard let uri = urlComponents.url else { return  nil }

        self.value = uri.absoluteString
    }

    /// Creates a URI for a transfer beneficiary.
    /// - Parameter beneficiary: The transfer beneficiary.
    public init?(beneficiary: BeneficiaryAccountRepresentable) {
        var urlComponents = URLComponents()
        urlComponents.scheme = beneficiary.accountNumberKind.value
        urlComponents.host = beneficiary.accountNumber
        guard let uri = urlComponents.url else { return nil }
        self.value = uri.absoluteString
    }
}
