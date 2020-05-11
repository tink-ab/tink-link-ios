import Foundation

public final class InitiateTransferTask {

    public enum Status {
        case created
        case authenticating
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
        case executing
    }

    private let transferService: TransferService
    private let transferID: Transfer.ID
    private let completionHandler: (Result<Void, Error>) -> Void

    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var canceller: Cancellable?

    init(transferService: RESTTransferService, transferID: Transfer.ID, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.transferService = transferService
        self.transferID = transferID
        self.completionHandler = completionHandler
    }

    func transfer(id: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        return transferService.transferStatus(transferID: id, completion: completion)
    }

    public func cancel() {
        canceller?.cancel()
    }
}
