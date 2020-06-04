import Foundation

extension Account {
    /// A type representing the URI for making transfers.
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

extension Account.URI {
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

extension Account.URI {
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

        self.value = uri.absoluteString
    }
}

extension Account.URI {
    /// Creates a URI for an account.
    /// - Parameter account: The account.
    public init?(account: Account) {
        guard let uri = account.transferSourceIdentifiers?.first else { return  nil }

        self.value = uri.absoluteString
    }
}
