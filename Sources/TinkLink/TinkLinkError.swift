import Foundation
import TinkCore

/// Error that TinkLink can throw.
public struct TinkLinkError: Swift.Error, CustomStringConvertible {
    public struct Code: Hashable {
        enum Value {
            case credentialsAuthenticationFailed
            case temporaryCredentialsFailure
            case permanentCredentialsFailure
            case alreadyExists
            case credentialsDeleted
            case credentialsSessionExpired
            case cancelled
            case transferFailed
            case invalidBeneficiary
            case notFound
            case invalidArgument
            case permissionDenied
            case unauthenticated
            case failedPrecondition
            case unavailableForLegalReasons
            case internalError
        }

        var value: Value

        /// The authentication failed.
        public static let credentialsAuthenticationFailed = Self(value: .credentialsAuthenticationFailed)
        /// A temporary failure occurred.
        public static let temporaryCredentialsFailure = Self(value: .temporaryCredentialsFailure)
        /// A permanent failure occurred.
        public static let permanentCredentialsFailure = Self(value: .permanentCredentialsFailure)
        /// The resource already exists.
        public static let alreadyExists = Self(value: .alreadyExists)
        /// The credentials are deleted.
        public static let credentialsDeleted = Self(value: .credentialsDeleted)
        /// The credentials session was expired.
        public static let credentialsSessionExpired = Self(value: .credentialsSessionExpired)
        /// The task was cancelled.
        public static let cancelled = Self(value: .cancelled)
        /// The transfer failed.
        public static let transferFailed = Self(value: .transferFailed)
        /// The beneficiary was invalid.
        public static let invalidBeneficiary = Self(value: .invalidBeneficiary)
        /// The resource could not be found.
        public static let notFound = Self(value: .notFound)

        public static let invalidArgument = Self(value: .invalidArgument)
        public static let permissionDenied = Self(value: .permissionDenied)
        public static let unauthenticated = Self(value: .unauthenticated)
        public static let failedPrecondition = Self(value: .failedPrecondition)
        public static let unavailableForLegalReasons = Self(value: .unavailableForLegalReasons)
        public static let internalError = Self(value: .internalError)

        public static func ~=(lhs: Self, rhs: Swift.Error) -> Bool {
            lhs == (rhs as? TinkLinkError)?.code
        }
    }

    public let code: Code
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
    /// The resource already exists.
    ///
    /// The payload from the backend can be found in the message property.
    public static let alreadyExists: Code = .alreadyExists
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
    /// The beneficiary was invalid.
    /// If you get this error, make sure that the parameters for `addBeneficiary` are correct.
    ///
    /// The payload from the backend can be found in the message property.
    public static let invalidBeneficiary: Code = .invalidBeneficiary
    /// The resource could not be found.
    ///
    /// The payload from the backend can be found in the message property.
    public static let notFound: Code = .notFound

    public static let invalidArgument: Code = .invalidArgument
    public static let permissionDenied: Code = .permissionDenied
    public static let unauthenticated: Code = .unauthenticated
    public static let failedPrecondition: Code = .failedPrecondition
    public static let unavailableForLegalReasons: Code = .unavailableForLegalReasons
    public static let internalError: Code = .internalError

    static func credentialsAuthenticationFailed(_ message: String?) -> Self {
        .init(code: .credentialsAuthenticationFailed, message: message)
    }

    static func temporaryCredentialsFailure(_ message: String?) -> Self {
        .init(code: .temporaryCredentialsFailure, message: message)
    }

    static func permanentCredentialsFailure(_ message: String?) -> Self {
        .init(code: .permanentCredentialsFailure, message: message)
    }

    static func alreadyExists(_ message: String?) -> Self {
        .init(code: .alreadyExists, message: message)
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

    static func invalidBeneficiary(_ message: String?) -> Self {
        .init(code: .invalidBeneficiary, message: message)
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
    static func unauthenticated(_ message: String?) -> Self {
        .init(code: .unauthenticated, message: message)
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

    init?(addBeneficiaryError error: Swift.Error) {
        switch error {
        case ServiceError.invalidArgument(let message):
            self = .invalidBeneficiary(message)
        default:
            if let tinkLinkError = error.tinkLinkError as? TinkLinkError {
                self = tinkLinkError
            } else {
                return nil
            }
        }
    }
}

extension Swift.Error {
    var tinkLinkError: Swift.Error {
        guard let serviceError = self as? ServiceError else { return self }
        switch serviceError {
        case .cancelled:
            return TinkLinkError.cancelled(nil)
        case .invalidArgument(let message):
            return TinkLinkError.invalidArgument(message)
        case .notFound(let message):
            return TinkLinkError.notFound(message)
        case .alreadyExists(let message):
            return TinkLinkError.alreadyExists(message)
        case .permissionDenied(let message):
            return TinkLinkError.permissionDenied(message)
        case .unauthenticated(let message):
            return TinkLinkError.unauthenticated(message)
        case .failedPrecondition(let message):
            return TinkLinkError.failedPrecondition(message)
        case .unavailableForLegalReasons(let message):
            return TinkLinkError.unavailableForLegalReasons(message)
        case .internalError(let message):
            return TinkLinkError.internalError(message)
        @unknown default:
            return self
        }
    }
}
