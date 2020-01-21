import Foundation
public protocol ScopeType: CustomStringConvertible {
    static var name: String { get }
}

/// Access to Tink is divided into scopes. The available scopes for Tink's APIs can be found in Tink console
extension TinkLink {
    public struct Scope: CustomStringConvertible {
        public let scopes: [ScopeType]
        public let description: String
        public init(scopes: [ScopeType]) {
            precondition(!scopes.isEmpty, "Tinklink scope is empty.")
            self.scopes = scopes

            self.description = scopes.map { $0.description }.joined(separator: ",")
        }
    }
}

extension TinkLink.Scope {
    enum Access: String {
        case read, write, grant, revoke, refresh, categorize, execute, create, delete, webHooks = "web_hooks"
    }

    /// Access to all the user's account information, including balances.
    public struct Accounts: ScopeType {
        public static let name = "accounts"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Activities: ScopeType {
        public static let name = "activities"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    public struct Authorization: ScopeType {
        public static let name = "authorization"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let grant = Self(access: .grant)
        public static let revoke = Self(access: .revoke)
    }

    public struct Budgets: ScopeType {
        public static let name = "budgets"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Calendar: ScopeType {
        public static let name = "calendar"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    public struct Categories: ScopeType {
        public static let name = "categories"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    public struct Contacts: ScopeType {
        public static let name = "contacts"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    /// Access to the information describing the user's different bank credentials connected to Tink.
    public struct Credentials: ScopeType {
        public static let name = "credentials"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
        public static let refresh = Self(access: .refresh)
    }

    public struct DataExports: ScopeType {
        public static let name = "data-exports"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Documents: ScopeType {
        public static let name = "documents"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Follow: ScopeType {
        public static let name = "follow"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    /// Access to the user's personal information that can be used for identification purposes.
    public struct Identity: ScopeType {
        public static let name = "identity"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Insights: ScopeType {
        public static let name = "insights"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    /// Access to the user's portfolios and underlying financial instruments.
    public struct Investments: ScopeType {
        public static let name = "investments"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    public struct Payment: ScopeType {
        public static let name = "payment"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Properties: ScopeType {
        public static let name = "properties"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
    }

    public struct Providers: ScopeType {
        public static let name = "providers"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    /// Access to all the user's statistics, which can include filters on statistic.type.
    public struct Statistics: ScopeType {
        public static let name = "statistics"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    public struct Suggestions: ScopeType {
        public static let name = "suggestions"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
    }

    /// Access to all the user's transactional data.
    public struct Transactions: ScopeType {
        public static let name = "transactions"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
        public static let categorize = Self(access: .categorize)
    }

    public struct Transfer: ScopeType {
        public static let name = "transfer"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let execute = Self(access: .execute)
    }

    /// Access to user profile data such as e-mail, date of birth, etc.
    public struct User: ScopeType {
        public static let name = "user"
        public var description: String {
            return Self.name + ":" + access.rawValue
        }

        private let access: TinkLink.Scope.Access

        public static let read = Self(access: .read)
        public static let write = Self(access: .write)
        public static let create = Self(access: .create)
        public static let delete = Self(access: .delete)
        public static let webHooks = Self(access: .webHooks)
    }
}
