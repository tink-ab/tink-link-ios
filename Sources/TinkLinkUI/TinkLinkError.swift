import Foundation
import TinkLink

public struct TinkLinkError: Error, Equatable, CustomStringConvertible {
    private enum Code: Int {
        case userCancelled = 1
        case unableToFetchProviders
        case missingInternetConnection
        case credentialsNotFound
        case providerNotFound
        case unableToOpenThirdPartyApp
        case unauthenticated
        case internalError
    }

    private var code: Code

    private init(code: Code) {
        self.code = code
    }

    public var description: String {
        return "TinkLinkError.\(String(describing: self.code))"
    }

    /// User cancelled the flow.
    public static let userCancelled: TinkLinkError = .init(code: .userCancelled)
    /// Unable to fetch providers.
    public static let unableToFetchProviders: TinkLinkError = .init(code: .unableToFetchProviders)
    /// Unable to fetch providers.
    public static let missingInternetConnection: TinkLinkError = .init(code: .missingInternetConnection)
    /// The credentials could not be found.
    public static let credentialsNotFound: TinkLinkError = .init(code: .credentialsNotFound)
    /// The provider could not be found.
    public static let providerNotFound: TinkLinkError = .init(code: .providerNotFound)
    /// Tink Link was not able to open the third party app.
    public static let unableToOpenThirdPartyApp: TinkLinkError = .init(code: .unableToOpenThirdPartyApp)
    public static let unauthenticated: TinkLinkError = .init(code: .unauthenticated)
    public static let internalError: TinkLinkError = .init(code: .internalError)

    init?(error: Error) {
        if let error = error as? ProviderController.Error {
            switch error {
            case .emptyProviderList:
                self = .unableToFetchProviders
            case .providerNotFound:
                self = .providerNotFound
            }
        } else if case ServiceError.unauthenticated = error {
            self = .unauthenticated
        } else if let error = error as? URLError, error.code == .notConnectedToInternet {
            self = .missingInternetConnection
        } else {
            return nil
        }
    }
}
