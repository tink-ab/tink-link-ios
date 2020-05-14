import Foundation

public final class TransferContext {
    private let tink: Tink
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    public enum DestinationAccountKind {
        case all
        case availableForAccount(Transfer.TransferEntityURI)
    }

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
        amount: ExactNumber,
        currencyCode: CurrencyCode,
        credentialsID: Credentials.ID,
        sourceURI: Transfer.TransferEntityURI,
        destinationURI: Transfer.TransferEntityURI,
        message: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void,
        completion: @escaping (Result<SignableOperation, Error>) -> Void
    ) -> InitiateTransferTask? {
        let task = InitiateTransferTask(transferService: transferService, credentialsService: credentialsService, appUri: tink.configuration.redirectURI, progressHandler: progressHandler, completionHandler: completion)

        let transfer = Transfer(
            amount: amount,
            id: nil,
            credentialsID: credentialsID,
            currency: currencyCode,
            sourceMessage: message,
            destinationMessage: message,
            dueDate: nil,
            messageType: .freeText,
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

    public func fetchSourceAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    public func fetchDestinationAccounts(forSourceAccount sourceUri: Transfer.TransferEntityURI, completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    public func fetchAllDestinationAccounts(completion: @escaping (Result<[Account.ID: [TransferDestination]], Error>) -> Void) -> RetryCancellable? {
        transferService.accounts(destinationUris: []) { result in
            do {
                let accounts = try result.get()
                let mappedTransferDestinations = accounts.reduce(into: [Account.ID: [TransferDestination]]()) {
                    let destinations = $1.transferDestinations ?? []
                    $0[$1.id] = destinations
                }
                completion(.success(mappedTransferDestinations))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
