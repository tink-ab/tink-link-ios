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

    init?(addBeneficiaryError error: Swift.Error) {
        switch error {
        case ServiceError.invalidArgument(let message):
            self = .invalidBeneficiary(message)
        default:
            self.init(serviceError: error)
        }
    }

    init?(serviceError error: Swift.Error) {
        guard let serviceError = error as? ServiceError else { return nil }
        switch serviceError {
        case .cancelled:
            self = .cancelled(nil)
        case .invalidArgument(let message):
            return nil
        case .notFound(let message):
            self = .notFound(message)
        case .alreadyExists(let message):
            return nil
        case .permissionDenied(let message):
            return nil
        case .unauthenticated(let message):
            return nil
        case .failedPrecondition(let message):
            return nil
        case .unavailableForLegalReasons(let message):
            return nil
        case .internalError(let message):
            return nil
        @unknown default:
            return nil
        }
    }
}
