import Foundation

/// An error returned by TinkLinkUI when something went wrong during the aggregation.
public enum TinkLinkError: Error {
    /// User cancelled the flow.
    case userCancelled
    /// Unable to fetch any back.
    case unableToFetchBanks
    /// Lost internet connection.
    case missingInternetConnection

    init?(error: Error) {
        if let error = error as? ProviderController.Error {
            switch error {
            case .emptyProviderList:
                self = .unableToFetchBanks
            case .missingInternetConnection:
                self = .missingInternetConnection
            }
        } else {
            return nil
        }
    }
}
