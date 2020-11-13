import Foundation
import TinkLink

public struct TinkLinkError: Error, Equatable, CustomStringConvertible {
    public struct Code: Hashable {
        enum Value: Int {
            case unknown
            case userCancelled
            case unableToFetchProviders
            case missingInternetConnection
            case credentialsNotFound
            case providerNotFound
            case unableToOpenThirdPartyApp
            case unauthenticated
            case internalError
        }

        var value: Value { Value(rawValue: rawValue) ?? .unknown }

        let rawValue: Int

        public static let userCancelled = Self(rawValue: Value.userCancelled.rawValue)
        public static let unableToFetchProviders = Self(rawValue: Value.unableToFetchProviders.rawValue)
        public static let missingInternetConnection = Self(rawValue: Value.missingInternetConnection.rawValue)
        public static let credentialsNotFound = Self(rawValue: Value.credentialsNotFound.rawValue)
        public static let providerNotFound = Self(rawValue: Value.providerNotFound.rawValue)
        public static let unableToOpenThirdPartyApp = Self(rawValue: Value.unableToOpenThirdPartyApp.rawValue)
        public static let unauthenticated = Self(rawValue: Value.unauthenticated.rawValue)
        public static let internalError = Self(rawValue: Value.internalError.rawValue)

        public static func ~=(lhs: Self, rhs: Swift.Error) -> Bool {
            lhs == (rhs as? TinkLinkError)?.code
        }
    }

    public var code: Code

    init(code: Code) {
        self.code = code
    }

    public var description: String {
        return "TinkLinkError.\(code.value)"
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
    public static let unauthenticated: Code = .unauthenticated
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
            self = .init(code: .unauthenticated)
        } else if let error = error as? URLError, error.code == .notConnectedToInternet {
            self = .init(code: .missingInternetConnection)
        } else {
            return nil
        }
    }
}
