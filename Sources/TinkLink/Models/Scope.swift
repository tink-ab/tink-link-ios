import Foundation
/// Access to Tink is divided into scopes which grant access to different API endpoints.
/// Each API customer has a set of scopes which control the maximum permitted data access.
/// To see the total set of scopes that you can use, go to app settings in the Tink Console.
public struct Scope {
    let name: String
    let access: [String]
}

extension Scope {
    var scopeDescription: String {
        access.map { "\(name):\($0)" }.joined(separator: ",")
    }
}

extension Scope: Equatable {}

extension Array where Element == Scope {
    var scopeDescription: String { map(\.scopeDescription).joined(separator: ",") }
}

public extension Scope {

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

    /// Access to all the user's account information, including balances.
    static func accounts(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "accounts", access: access.map(\.rawValue))
    }

    static func activities(_ access: ReadAccess...) -> Scope {
        return Scope(name: "activities", access: access.map(\.rawValue))
    }

    static func authorization(_ access: AuthorizationAccess...) -> Scope {
        return Scope(name: "authorization", access: access.map(\.rawValue))
    }

    static func beneficiaries(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "beneficiaries", access: access.map(\.rawValue))
    }

    static func budgets(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "budgets", access: access.map(\.rawValue))
    }

    static func calendar(_ access: ReadAccess...) -> Scope {
        return Scope(name: "calendar", access: access.map(\.rawValue))
    }

    static func categories(_ access: ReadAccess...) -> Scope {
        return Scope(name: "categories", access: access.map(\.rawValue))
    }

    static func contacts(_ access: ReadAccess...) -> Scope {
        return Scope(name: "contacts", access: access.map(\.rawValue))
    }

    /// Access to the information describing the user's different bank credentials connected to Tink.
    static func credentials(_ access: CredentialsAccess...) -> Scope {
        return Scope(name: "credentials", access: access.map(\.rawValue))
    }

    static func dataExports(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "data-exports", access: access.map(\.rawValue))
    }

    static func documents(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "documents", access: access.map(\.rawValue))
    }

    static func follow(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "follow", access: access.map(\.rawValue))
    }

    /// Access to the user's personal information that can be used for identification purposes.
    static func identity(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "identity", access: access.map(\.rawValue))
    }

    static func insights(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "insights", access: access.map(\.rawValue))
    }

    /// Access to the user's portfolios and underlying financial instruments.
    static func investments(_ access: ReadAccess...) -> Scope {
        return Scope(name: "investments", access: access.map(\.rawValue))
    }

    static func properties(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "properties", access: access.map(\.rawValue))
    }

    static func providers(_ access: ReadAccess...) -> Scope {
        return Scope(name: "providers", access: access.map(\.rawValue))
    }

    /// Access to all the user's statistics, which can include filters on statistic.type.
    static func statistics(_ access: ReadAccess...) -> Scope {
        return Scope(name: "statistics", access: access.map(\.rawValue))
    }

    static func suggestions(_ access: ReadAccess...) -> Scope {
        return Scope(name: "suggestions", access: access.map(\.rawValue))
    }

    /// Access to all the user's transactional data.
    static func transactions(_ access: TransactionAccess...) -> Scope {
        return Scope(name: "transactions", access: access.map(\.rawValue))
    }

    static func transfer(_ access: TransferAccess...) -> Scope {
        return Scope(name: "transfer", access: access.map(\.rawValue))
    }

    /// Access to user profile data such as e-mail, date of birth, etc.
    static func user(_ access: UserAccess...) -> Scope {
        return Scope(name: "user", access: access.map(\.rawValue))
    }
}
