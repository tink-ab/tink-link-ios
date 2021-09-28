import Foundation
import TinkLink

public struct TinkLinkUIError: Error, CustomStringConvertible {
    public struct Code: Hashable {
        enum Value {
            case userCancelled
            // Deprecation: 1.3.1
            @available(*, deprecated, message: "unableToFetchProviders is deprecated.")
            case unableToFetchProviders
            case missingInternetConnection
            case credentialsNotFound
            case providerNotFound
            case unableToOpenThirdPartyApp
            case failedToAddCredentials
            case notAuthenticated
            case internalError
        }

        var value: Value

        public static let userCancelled = Self(value: .userCancelled)
        @available(*, deprecated, message: "unableToFetchProviders is deprecated.")
        public static let unableToFetchProviders = Self(value: .unableToFetchProviders)
        public static let missingInternetConnection = Self(value: .missingInternetConnection)
        public static let credentialsNotFound = Self(value: .credentialsNotFound)
        public static let providerNotFound = Self(value: .providerNotFound)
        public static let unableToOpenThirdPartyApp = Self(value: .unableToOpenThirdPartyApp)
        public static let failedToAddCredentials = Self(value: .failedToAddCredentials)
        public static let notAuthenticated = Self(value: .notAuthenticated)
        public static let internalError = Self(value: .internalError)

        public static func ~= (lhs: Self, rhs: Swift.Error) -> Bool {
            lhs == (rhs as? TinkLinkUIError)?.code
        }
    }

    public var code: Code
    public private(set) var errorsByCredentialsID: [Credentials.ID: Error]?

    init(code: Code, errorsByCredentialsID: [Credentials.ID: Error]? = nil) {
        self.code = code
        self.errorsByCredentialsID = errorsByCredentialsID
    }

    public var description: String {
        return "TinkLinkUIError.\(code.value)"
    }

    /// User cancelled the flow.
    public static let userCancelled: Code = .userCancelled
    /// Unable to fetch providers.
    @available(*, deprecated, message: "unableToFetchProviders is deprecated.")
    public static let unableToFetchProviders: Code = .unableToFetchProviders
    /// Missing internet connection.
    public static let missingInternetConnection: Code = .missingInternetConnection
    /// The credentials could not be found.
    public static let credentialsNotFound: Code = .credentialsNotFound
    /// The provider could not be found.
    public static let providerNotFound: Code = .providerNotFound
    /// Tink Link was not able to open the third party app.
    public static let unableToOpenThirdPartyApp: Code = .unableToOpenThirdPartyApp
    public static let failedToAddCredentials: Code = .failedToAddCredentials
    public static let notAuthenticated: Code = .notAuthenticated
    public static let internalError: Code = .internalError

    init?(error: Error) {
        if let error = error as? ProviderController.Error {
            switch error {
            case .providerNotFound:
                self = .init(code: .providerNotFound)
            }
        } else if case TinkLinkError.notAuthenticated = error {
            self = .init(code: .notAuthenticated)
        } else if case TinkLinkError.notConnectedToInternet = error {
            self = .init(code: .missingInternetConnection)
        } else {
            return nil
        }
    }
}
