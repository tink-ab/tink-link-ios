import Foundation

public enum TinkLinkError: Error {
    case userCancelled
    case unableToFetchBanks
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
