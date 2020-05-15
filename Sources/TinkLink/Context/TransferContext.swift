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
        source: Account,
        destination: TransferDestination,
        sourceMessage: String? = nil,
        destinationMessage: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void,
        completion: @escaping (Result<SignableOperation, Error>) -> Void
    ) -> InitiateTransferTask? {
        guard let sourceURI = source.transferSourceIdentifiers?.first else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let destinationURI = destination.uri else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        let task = InitiateTransferTask(transferService: transferService, credentialsService: credentialsService, appUri: tink.configuration.redirectURI, progressHandler: progressHandler, completionHandler: completion)

        let transfer = Transfer(
            amount: amount.value,
            id: nil,
            credentialsID: source.credentialsID,
            currency: amount.currencyCode,
            sourceMessage: sourceMessage,
            destinationMessage: destinationMessage,
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

    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    public func fetchDestinationAccounts(forSource account: Account, completion: @escaping (Result<[TransferDestination], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: []) { result in
            do {
                let accounts = try result.get()
                let transferDestinations = accounts.first { $0.id == account.id }?.transferDestinations ?? []
                completion(.success(transferDestinations))
            } catch {
                completion(.failure(error))
            }
        }
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
