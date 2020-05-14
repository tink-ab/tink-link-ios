import Foundation

public final class TransferContext {
    private let tink: Tink
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    public convenience init(tink: Tink = .shared) {
        let transferService = RESTTransferService(client: tink.client)
        let credentialsService = RESTCredentialsService(client: tink.client)
        self.init(tink: tink, transferService: transferService, credentialsService: credentialsService)
    }

    init(tink: Tink, transferService: TransferService, credentialsService: CredentialsService) {
        self.tink = tink
        self.transferService = transferService
        self.credentialsService = credentialsService
    }

    public func initiateTransfer(
        amount: CurrencyDenominatedAmount,
        credentialsID: Credentials.ID,
        sourceURI: Transfer.TransferEntityURI,
        destinationURI: Transfer.TransferEntityURI,
        message: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void,
        completion: @escaping (Result<SignableOperation, Error>) -> Void
    ) -> InitiateTransferTask? {
        let task = InitiateTransferTask(transferService: transferService, credentialsService: credentialsService, appUri: tink.configuration.redirectURI, progressHandler: progressHandler, completionHandler: completion)

        let transfer = Transfer(
            amount: amount.value,
            id: nil,
            credentialsID: credentialsID,
            currency: amount.currencyCode,
            sourceMessage: message,
            destinationMessage: message,
            dueDate: nil,
            destinationUri: destinationURI,
            sourceUri: sourceURI
        )

        task.canceller = transferService.transfer(transfer: transfer) { [weak task] result in
            do {
                let signableOperation = try result.get()
                task?.startObserving(signableOperation)
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }

    public func sourceAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }
}
