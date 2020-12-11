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
            case invalidArguments
            case missingRequiredScope
            case notAuthenticated
            case tooManyRequests
            case unavailableForLegalReasons
            case internalError
            case notConnectedToInternet
            case networkFailure
            case thirdPartyAppAuthenticationFailed
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

        /// A required parameter was not set or an input parameter was invalid.
        public static let invalidArguments = Self(value: .invalidArguments)

        /// The access token is missing a required scope.
        public static let missingRequiredScope = Self(value: .missingRequiredScope)

        /// The user is not authenticated.
        public static let notAuthenticated = Self(value: .notAuthenticated)

        /// Request rate limit is exceeded.
        public static let tooManyRequests = Self(value: .tooManyRequests)

        /// The request cannot be fulfilled because of legal/contractual reasons.
        public static let unavailableForLegalReasons = Self(value: .unavailableForLegalReasons)

        /// An internal TinkLink error.
        public static let internalError = Self(value: .internalError)

        /// Missing internet connection.
        public static let notConnectedToInternet = Self(value: .notConnectedToInternet)

        /// Network error.
        public static let networkFailure = Self(value: .networkFailure)

        /// Authentication with third party app failed.
        public static let thirdPartyAppAuthenticationFailed = Self(value: .thirdPartyAppAuthenticationFailed)

        public static func ~= (lhs: Self, rhs: Swift.Error) -> Bool {
            lhs == (rhs as? TinkLinkError)?.code
        }
    }

    /// The error code.
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

    /// A required parameter was not set or an input parameter was invalid.
    ///
    /// The payload from the backend can be found in the message property.
    public static let invalidArguments: Code = .invalidArguments

    /// The access token is missing a required scope.
    ///
    /// The payload from the backend can be found in the message property.
    public static let missingRequiredScope: Code = .missingRequiredScope

    /// The user is not authenticated.
    ///
    /// The payload from the backend can be found in the message property.
    public static let notAuthenticated: Code = .notAuthenticated

    /// Request rate limit is exceeded.
    ///
    /// The payload from the backend can be found in the message property.
    public static let tooManyRequests: Code = .tooManyRequests

    /// The request cannot be fulfilled because of legal/contractual reasons.
    ///
    /// The payload from the backend can be found in the message property.
    public static let unavailableForLegalReasons: Code = .unavailableForLegalReasons

    /// An internal TinkLink error.
    public static let internalError: Code = .internalError

    /// Missing internet connection.
    public static let notConnectedToInternet: Code = .notConnectedToInternet

    /// Network error.
    public static let networkFailure: Code = .networkFailure

    /// Authentication with third party app failed.
    public static let thirdPartyAppAuthenticationFailed: Code = .thirdPartyAppAuthenticationFailed

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

    static func invalidArguments(_ message: String?) -> Self {
        .init(code: .invalidArguments, message: message)
    }

    static func missingRequiredScope(_ message: String?) -> Self {
        .init(code: .missingRequiredScope, message: message)
    }

    static func notAuthenticated(_ message: String?) -> Self {
        .init(code: .notAuthenticated, message: message)
    }

    static func tooManyRequests(_ message: String?) -> Self {
        .init(code: .tooManyRequests, message: message)
    }

    static func unavailableForLegalReasons(_ message: String?) -> Self {
        .init(code: .unavailableForLegalReasons, message: message)
    }

    static func internalError(_ message: String?) -> Self {
        .init(code: .internalError, message: message)
    }
}
