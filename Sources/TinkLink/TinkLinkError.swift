import Foundation
import TinkCore

/// Error that TinkLink can throw.
public struct TinkLinkError: Swift.Error, CustomStringConvertible {
    public struct Code: Hashable {
        enum Value {
            case credentialsAuthenticationFailed
            case temporaryCredentialsFailure
            case permanentCredentialsFailure
            case credentialsAlreadyExists
            case credentialsDeleted
            case credentialsSessionExpired
            case cancelled
            case transferFailed
            case notFound
            case invalidArgument
            case permissionDenied
            case notAuthenticated
            case failedPrecondition
            case unavailableForLegalReasons
            case internalError
            case notConnectedToInternet
            case networkFailure
        }

        var value: Value

        /// The authentication failed.
        public static let credentialsAuthenticationFailed = Self(value: .credentialsAuthenticationFailed)

        /// A temporary failure occurred.
        public static let temporaryCredentialsFailure = Self(value: .temporaryCredentialsFailure)

        /// A permanent failure occurred.
        public static let permanentCredentialsFailure = Self(value: .permanentCredentialsFailure)

        /// The credentials already exists.
        public static let credentialsAlreadyExists = Self(value: .credentialsAlreadyExists)

        /// The credentials are deleted.
        public static let credentialsDeleted = Self(value: .credentialsDeleted)

        /// The credentials session was expired.
        public static let credentialsSessionExpired = Self(value: .credentialsSessionExpired)

        /// The task was cancelled.
        public static let cancelled = Self(value: .cancelled)

        /// The transfer failed.
        public static let transferFailed = Self(value: .transferFailed)

        /// The resource could not be found.
        public static let notFound = Self(value: .notFound)

        public static let invalidArgument = Self(value: .invalidArgument)
        public static let permissionDenied = Self(value: .permissionDenied)
        public static let notAuthenticated = Self(value: .notAuthenticated)
        public static let failedPrecondition = Self(value: .failedPrecondition)
        public static let unavailableForLegalReasons = Self(value: .unavailableForLegalReasons)
        public static let internalError = Self(value: .internalError)
        public static let notConnectedToInternet = Self(value: .notConnectedToInternet)
        public static let networkFailure = Self(value: .networkFailure)

        public static func ~=(lhs: Self, rhs: Swift.Error) -> Bool {
            lhs == (rhs as? TinkLinkError)?.code
        }
    }

    public let code: Code

    // A payload from the backend.
    public let message: String?

    init(code: Code, message: String? = nil) {
        self.code = code
        self.message = message
    }

    public var description: String {
        return "TinkLinkError.\(code.value)"
    }

    /// The authentication failed.
    ///
    /// The payload from the backend can be found in the message property.
    public static let credentialsAuthenticationFailed: Code = .credentialsAuthenticationFailed

    /// A temporary failure occurred.
    ///
    /// The payload from the backend can be found in the message property.
    public static let temporaryCredentialsFailure: Code = .temporaryCredentialsFailure

    /// A permanent failure occurred.
    ///
    /// The payload from the backend can be found in the message property.
    public static let permanentCredentialsFailure: Code = .permanentCredentialsFailure

    /// The credentials already exists.
    ///
    /// The payload from the backend can be found in the message property.
    public static let credentialsAlreadyExists: Code = .credentialsAlreadyExists

    /// The credentials are deleted.
    ///
    /// The payload from the backend can be found in the message property.
    public static let credentialsDeleted: Code = .credentialsDeleted

    /// The credentials session was expired.
    ///
    /// The payload from the backend can be found in the message property.
    public static let credentialsSessionExpired: Code = .credentialsSessionExpired

    /// The task was cancelled.
    public static let cancelled: Code = .cancelled

    /// The transfer failed.
    ///
    /// The payload from the backend can be found in the message property.
    public static let transferFailed: Code = .credentialsSessionExpired

    /// The resource could not be found.
    ///
    /// The payload from the backend can be found in the message property.
    public static let notFound: Code = .notFound

    public static let invalidArgument: Code = .invalidArgument
    public static let permissionDenied: Code = .permissionDenied
    public static let notAuthenticated: Code = .notAuthenticated
    public static let failedPrecondition: Code = .failedPrecondition
    public static let unavailableForLegalReasons: Code = .unavailableForLegalReasons
    public static let internalError: Code = .internalError
    public static let notConnectedToInternet: Code = .notConnectedToInternet
    public static let networkFailure: Code = .networkFailure

    static func credentialsAuthenticationFailed(_ message: String?) -> Self {
        .init(code: .credentialsAuthenticationFailed, message: message)
    }

    static func temporaryCredentialsFailure(_ message: String?) -> Self {
        .init(code: .temporaryCredentialsFailure, message: message)
    }

    static func permanentCredentialsFailure(_ message: String?) -> Self {
        .init(code: .permanentCredentialsFailure, message: message)
    }

    static func credentialsAlreadyExists(_ message: String?) -> Self {
        .init(code: .credentialsAlreadyExists, message: message)
    }

    static func credentialsDeleted(_ message: String?) -> Self {
        .init(code: .credentialsDeleted, message: message)
    }

    static func credentialsSessionExpired(_ message: String?) -> Self {
        .init(code: .credentialsSessionExpired, message: message)
    }

    static func cancelled(_ message: String?) -> Self {
        .init(code: .cancelled, message: message)
    }

    static func transferFailed(_ message: String?) -> Self {
        .init(code: .transferFailed, message: message)
    }

    static func notFound(_ message: String?) -> Self {
        .init(code: .notFound, message: message)
    }

    static func invalidArgument(_ message: String?) -> Self {
        .init(code: .invalidArgument, message: message)
    }

    static func permissionDenied(_ message: String?) -> Self {
        .init(code: .permissionDenied, message: message)
    }

    static func notAuthenticated(_ message: String?) -> Self {
        .init(code: .notAuthenticated, message: message)
    }

    static func failedPrecondition(_ message: String?) -> Self {
        .init(code: .failedPrecondition, message: message)
    }

    static func unavailableForLegalReasons(_ message: String?) -> Self {
        .init(code: .unavailableForLegalReasons, message: message)
    }

    static func internalError(_ message: String?) -> Self {
        .init(code: .internalError, message: message)
    }
}

extension Swift.Error {
    var tinkLinkError: Swift.Error {
        switch self {
        case let error as URLError where error.code == .notConnectedToInternet:
            return TinkLinkError(code: .notConnectedToInternet, message: error.localizedDescription)
        case let error as URLError:
            return TinkLinkError(code: .networkFailure, message: error.localizedDescription)
        case let error as ServiceError:
            switch error {
            case .cancelled:
                return TinkLinkError.cancelled(nil)
            case .invalidArgument(let message):
                return TinkLinkError.invalidArgument(message)
            case .notFound(let message):
                return TinkLinkError.notFound(message)
            case .alreadyExists:
                return self
            case .permissionDenied(let message):
                return TinkLinkError.permissionDenied(message)
            case .unauthenticated(let message):
                return TinkLinkError.notAuthenticated(message)
            case .failedPrecondition(let message):
                return TinkLinkError.failedPrecondition(message)
            case .unavailableForLegalReasons(let message):
                return TinkLinkError.unavailableForLegalReasons(message)
            case .internalError(let message):
                return TinkLinkError.internalError(message)
            @unknown default:
                return self
            }
        default:
            return self
        }
    }
}
