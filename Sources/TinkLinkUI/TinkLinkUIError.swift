import Foundation
import TinkLink

public struct TinkLinkUIError: Error, Equatable, CustomStringConvertible {
    public struct Code: Hashable {
        enum Value {
            case userCancelled
            case unableToFetchProviders
            case missingInternetConnection
            case credentialsNotFound
            case providerNotFound
            case unableToOpenThirdPartyApp
            case notAuthenticated
            case internalError
        }

        var value: Value

        public static let userCancelled = Self(value: .userCancelled)
        public static let unableToFetchProviders = Self(value: .unableToFetchProviders)
        public static let missingInternetConnection = Self(value: .missingInternetConnection)
        public static let credentialsNotFound = Self(value: .credentialsNotFound)
        public static let providerNotFound = Self(value: .providerNotFound)
        public static let unableToOpenThirdPartyApp = Self(value: .unableToOpenThirdPartyApp)
        public static let notAuthenticated = Self(value: .notAuthenticated)
        public static let internalError = Self(value: .internalError)

        public static func ~=(lhs: Self, rhs: Swift.Error) -> Bool {
            lhs == (rhs as? TinkLinkUIError)?.code
        }
    }

    public var code: Code

    init(code: Code) {
        self.code = code
    }

    public var description: String {
        return "TinkLinkUIError.\(code.value)"
    }

    /// User cancelled the flow.
    public static let userCancelled: Code = .userCancelled
    /// Unable to fetch providers.
    public static let unableToFetchProviders: Code = .unableToFetchProviders
    /// Unable to fetch providers.
    public static let missingInternetConnection: Code = .missingInternetConnection
    /// The credentials could not be found.
    public static let credentialsNotFound: Code = .credentialsNotFound
    /// The provider could not be found.
    public static let providerNotFound: Code = .providerNotFound
    /// Tink Link was not able to open the third party app.
    public static let unableToOpenThirdPartyApp: Code = .unableToOpenThirdPartyApp
    public static let notAuthenticated: Code = .notAuthenticated
    public static let internalError: Code = .internalError

    init?(error: Error) {
        if let error = error as? ProviderController.Error {
            switch error {
            case .emptyProviderList:
                self = .init(code: .unableToFetchProviders)
            case .providerNotFound:
                self = .init(code: .providerNotFound)
            }
        } else if case ServiceError.unauthenticated = error {
            self = .init(code: .notAuthenticated)
        } else if let error = error as? URLError, error.code == .notConnectedToInternet {
            self = .init(code: .missingInternetConnection)
        } else {
            return nil
        }
    }
}
