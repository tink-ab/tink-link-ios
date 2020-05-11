import Foundation

public final class InitiateTransferTask {

    public enum Status {
        case created
        case authenticating
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
        case executing
    }

    // TODO: Make a protocol for transfer service
    private let transferService: RESTTransferService

    public func cancel() {
    }
}
