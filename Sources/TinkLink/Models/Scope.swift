import Foundation

public struct ScopeType {
    let name: String
    let access: [String]
}

public extension ScopeType {
    var scopeDescription: String {
        access.map { "\(name):\($0)" }.joined(separator: ",")
    }
}

// MARK: - Defining Access Scopes
extension Tink {
    /// Access to Tink is divided into scopes. The available scopes for Tink's APIs can be found in Tink console
    public struct Scope: CustomStringConvertible {
        public let scopes: [ScopeType]
        public let description: String
        public init(scopes: [ScopeType]) {
            precondition(!scopes.isEmpty, "Tinklink scope is empty.")
            self.scopes = scopes

            self.description = scopes.map { $0.scopeDescription }.joined(separator: ",")
        }

        init() {
            self.scopes = []
            self.description = ""
        }
    }
}

public extension ScopeType {

    enum ReadAccess: String {
        case read
    }

    enum ReadWriteAccess: String {
        case read, write
    }

    enum AuthorizationAccess: String {
        case grant, read, revoke
    }

    enum CredentialsAccess: String {
        case read, write, refresh
    }

    enum TransactionAccess: String {
        case read, write, categorize
    }

    enum TransferAccess: String {
        case read, execute
    }

    enum UserAccess: String {
        case create, delete, read, webHooks = "web_hooks", write
    }

    static func accounts(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "accounts", access: access.map { $0.rawValue })
    }

    static func activities(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "activities", access: access.map { $0.rawValue })
    }

    static func authorization(_ access: AuthorizationAccess...) -> ScopeType {
        return ScopeType(name: "authorization", access: access.map { $0.rawValue })
    }

    static func budgets(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "budgets", access: access.map { $0.rawValue })
    }

    static func calendar(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "calendar", access: access.map { $0.rawValue })
    }

    static func categories(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "categories", access: access.map { $0.rawValue })
    }

    static func contacts(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "contacts", access: access.map { $0.rawValue })
    }

    static func credentials(_ access: CredentialsAccess...) -> ScopeType {
        return ScopeType(name: "credentials", access: access.map { $0.rawValue })
    }

    static func dataExports(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "data-exports", access: access.map { $0.rawValue })
    }

    static func documents(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "documents", access: access.map { $0.rawValue })
    }

    static func follow(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "follow", access: access.map { $0.rawValue })
    }

    static func identity(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "identity", access: access.map { $0.rawValue })
    }

    static func insights(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "insights", access: access.map { $0.rawValue })
    }

    static func investments(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "investments", access: access.map { $0.rawValue })
    }

    static func properties(_ access: ReadWriteAccess...) -> ScopeType {
        return ScopeType(name: "properties", access: access.map { $0.rawValue })
    }

    static func providers(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "providers", access: access.map { $0.rawValue })
    }

    static func statistics(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "statistics", access: access.map { $0.rawValue })
    }

    static func suggestions(_ access: ReadAccess...) -> ScopeType {
        return ScopeType(name: "suggestions", access: access.map { $0.rawValue })
    }

    static func transactions(_ access: TransactionAccess...) -> ScopeType {
        return ScopeType(name: "transactions", access: access.map { $0.rawValue })
    }

    static func transfer(_ access: TransferAccess...) -> ScopeType {
        return ScopeType(name: "transfer", access: access.map { $0.rawValue })
    }

    static func user(_ access: UserAccess...) -> ScopeType {
        return ScopeType(name: "user", access: access.map { $0.rawValue })
    }
}
