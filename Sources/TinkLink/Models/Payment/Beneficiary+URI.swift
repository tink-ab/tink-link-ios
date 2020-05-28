import Foundation

extension Beneficiary {
    /// A type representing the URI for reciving transfers.
    ///
    /// A URI is composed with two parts, a kind with value of e.g. `iban` and an account number.
    public struct URI {
        let uri: URL

        public var value: String { uri.absoluteString }
    }
}

extension Beneficiary.URI {
    /// A type representing an kind of account URI.
    public struct Kind: ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        /// Creates a kind.
        /// - Parameter value: The `String` that represents the account kind.
        public init(_ value: String) {
            self.value = value
        }

        /// The `String` that represent the account kind.
        public let value: String

        public static let iban: Kind = "iban"
        public static let se: Kind = "se"
        public static let seBankGiro: Kind = "se-bg"
        public static let sePlusGiro: Kind = "se-pg"
        public static let sortCode: Kind = "sort-code"
    }
}

extension Beneficiary.URI {
    /// Creates a URI.
    ///
    /// Returns `nil` if a URI cannot be formed with the kind and account number (for example if the number contains characters that are illegal, or is an empty string).
    ///
    /// - Parameters:
    ///   - kind: The kind of account URI.
    ///   - accountNumber: The account number. The structure of this parameter depends on the `kind`.
    public init?(kind: Kind, accountNumber: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = kind.value
        urlComponents.host = accountNumber

        guard let uri = urlComponents.url else { return nil }

        self.init(uri: uri)
    }
}

extension Beneficiary.URI {
    /// Creates a URI for a beneficiary.
    /// - Parameter beneficiary: The beneficiary.
    public init?(beneficiary: Beneficiary) {
        guard let uri = beneficiary.uri else { return  nil }

        self.init(uri: uri)
    }
}
