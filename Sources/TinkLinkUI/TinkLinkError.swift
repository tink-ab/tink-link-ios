import Foundation
import TinkLink

/// An error returned by TinkLinkUI when something went wrong during the aggregation.
public enum TinkLinkError: Error {
    /// User cancelled the flow.
    case userCancelled
    /// Unable to fetch providers.
    case unableToFetchProviders
    /// Lost internet connection.
    case missingInternetConnection
    /// The credentials could not be found.
    case credentialsNotFound
    /// The provider could not be found.
    case providerNotFound
    /// Tink Link was not able to open the third party app.
    case unableToOpenThirdPartyApp(ThirdPartyAppAuthenticationTask.Error)

    case internalError

    init?(error: Error) {
        if let error = error as? ProviderController.Error {
            switch error {
            case .emptyProviderList:
                self = .unableToFetchProviders
            case .providerNotFound:
                self = .providerNotFound
            case .missingInternetConnection:
                self = .missingInternetConnection
            }
        } else {
            return nil
        }
    }
}
