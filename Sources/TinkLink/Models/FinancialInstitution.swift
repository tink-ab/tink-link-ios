extension Provider {
    /// The FinancialInstitution model represents a financial institution.
    public struct FinancialInstitution: Hashable {
        /// A unique identifier of a `FinancialInstitution`.
        public struct ID: Hashable, ExpressibleByStringLiteral {
            public init(stringLiteral value: String) {
                self.value = value
            }

            /// Creates an instance initialized to the given string value.
            /// - Parameter value: The value of the new instance.
            public init(_ value: String) {
                self.value = value
            }

            /// The string value of the ID.
            public let value: String
        }

        /// A unique identifier.
        ///
        /// Use this to group providers belonging the same financial institution.
        public let id: ID

        /// The name of the financial institution.
        public let name: String
    }
}
