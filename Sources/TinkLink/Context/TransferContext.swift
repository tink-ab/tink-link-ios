import Foundation
/// An object that you use to access the user's transfer and beneficiary account and initiate transfer.
public final class TransferContext {
    private let tink: Tink
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    // MARK: - Creating a Context

    /// Creates a context to access the user's transfer and beneficiary account and initiate transfer.
    ///
    /// - Parameter tink: Tink instance, will use the shared instance if nothing is provided.
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

    // MARK: - Initiate Transfer

    /// Initiate a transfer for the user.
    ///
    /// You need to handle authentication changes in `authenticationHandler` to successfuly initiate a transfer.
    /// Also if needed, you can get the progress status change in `progressHandler`, and present them accordingly.
    ///    initiateTransferTask = transferContext.initiateTransfer(
    ///        amount: CurrencyDenominatedAmount(value: amount, currencyCode: balance.currencyCode),
    ///        source: sourceAccount,
    ///        destination: transferDestination,
    ///        destinationMessage: message,
    ///        progressHandler: { status in
    ///            <#Present the progress status change if needed#>
    ///        },
    ///        authenticationHandler: { task in
    ///            switch task {
    ///            case .awaitingSupplementalInformation(let task):
    ///                <#Present form for supplemental information task#>
    ///            case .awaitingThirdPartyAppAuthentication(let task):
    ///                <#Handle the third party app deep link URL#>
    ///             }
    ///        },
    ///        completion: { [weak self] result in
    ///            <#Handle result#>
    ///        }
    ///    )
    /// - Parameters:
    ///   - amount: The amount and currency of the transfer.
    ///   - source: The transfer's source account.
    ///   - destination: The transfer's destination beneficiary.
    ///   - sourceMessage: Optional, The transfer description on the source account for the transfer.
    ///   - destinationMessage: The message to the recipient. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
    ///   - progressHandler: Indicates the state changes of initiating a transfer.
    ///   - completion: The block to execute when the transfer has been initiated successfuly or if it failed.
    ///   - result: A result representing either a transfer initiation receipt or an error.
    /// - Returns: The add credentials task.
    public func initiateTransfer(
        fromAccountWithURI: TransferEntityURI,
        toBeneficiaryWithURI: TransferEntityURI,
        amount: CurrencyDenominatedAmount,
        sourceMessage: String? = nil,
        destinationMessage: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        authenticationHandler: @escaping (InitiateTransferTask.AuthenticationTask) -> Void,
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
            destinationUri: fromAccountWithURI.uri,
            sourceUri: toBeneficiaryWithURI.uri
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
        authenticationHandler: @escaping (InitiateTransferTask.AuthenticationTask) -> Void,
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask? {
        guard let source = TransferEntityURI(account: source) else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let destination = TransferEntityURI(beneficiary: destination) else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        return initiateTransfer(fromAccountWithURI: source, toBeneficiaryWithURI: destination, amount: amount, destinationMessage: destinationMessage, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completion: completion)
    }

    // MARK: - Fetching Accounts

    /// Fetches transfer accounts for the user.
    ///
    /// - Parameter completion: A result representing either a list of accounts or an error.
    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    // MARK: - Fetching Beneficiaries

    /// Fetches transfer beneficiaries for an account.
    ///
    /// - Parameter account: Account for beneficiary to fetch
    /// - Parameter completion: A result representing either a list of beneficiaries or an error.
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

    // MARK: - Fetching All Beneficiaries

    /// Fetches all transfer beneficiaries for all accounts.
    ///
    /// - Parameter completion: A result representing either a list of account ID and beneficiaries pair or an error.
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
