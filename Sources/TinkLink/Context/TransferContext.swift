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
        from accountWithURI: TransferEntityURI,
        to beneficiaryWithURI: TransferEntityURI,
        amount: CurrencyDenominatedAmount,
        sourceMessage: String? = nil,
        destinationMessage: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        authenticationHandler: @escaping (InitiateTransferTask.Authentication) -> Void,
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask? {

        let task = InitiateTransferTask(transferService: transferService, credentialsService: credentialsService, appUri: tink.configuration.redirectURI, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completionHandler: completion)

        let transfer = Transfer(
            amount: amount.value,
            id: nil,
            credentialsID: nil,
            currency: amount.currencyCode,
            sourceMessage: sourceMessage,
            destinationMessage: destinationMessage,
            dueDate: nil,
            destinationUri: accountWithURI.uri,
            sourceUri: beneficiaryWithURI.uri
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

    public func initiateTransfer(
        from source: Account,
        to destination: Beneficiary,
        amount: CurrencyDenominatedAmount,
        sourceMessage: String? = nil,
        destinationMessage: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        authenticationHandler: @escaping (InitiateTransferTask.Authentication) -> Void,
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask? {
        guard let source = TransferEntityURI(account: source) else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let destination = TransferEntityURI(beneficiary: destination) else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        return initiateTransfer(from: source, to: destination, amount: amount, destinationMessage: destinationMessage, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completion: completion)
    }

    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    public func fetchBeneficiaries(for account: Account, completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        return transferService.beneficiaries { result in
            do {
                let beneficiaries = try result.get()
                let filteredBeneficiaries = beneficiaries.filter { $0.accountID == account.id }
                completion(.success(filteredBeneficiaries))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchAllBeneficiaries(completion: @escaping (Result<[Account.ID: [Beneficiary]], Error>) -> Void) -> RetryCancellable? {
        transferService.beneficiaries() { result in
            do {
                let beneficiaries = try result.get()
                let groupedBeneficiariesByAccountID = Dictionary(grouping: beneficiaries, by: \.accountID)
                completion(.success(groupedBeneficiariesByAccountID))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
