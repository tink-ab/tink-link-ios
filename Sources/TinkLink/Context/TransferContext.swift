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
    ///    initiateTransferTask = transferContext.initiateTransfer(
    ///        amount: CurrencyDenominatedAmount(value: amount, currencyCode: balance.currencyCode),
    ///        source: sourceAccount,
    ///        destination: transferDestination,
    ///        destinationMessage: message,
    ///        progressHandler: { [weak self] status in
    ///            <#Present the progress status change if needed#>
    ///        },
    ///        authenticationHandler: { [weak self] status in
    ///            switch status {
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
        amount: CurrencyDenominatedAmount,
        source: Account,
        destination: Beneficiary,
        sourceMessage: String? = nil,
        destinationMessage: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        authenticationHandler: @escaping (InitiateTransferTask.Authentication) -> Void,
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask? {
        guard let sourceURI = source.transferSourceIdentifiers?.first else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let destinationURI = destination.uri else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        let task = InitiateTransferTask(transferService: transferService, credentialsService: credentialsService, appUri: tink.configuration.redirectURI, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completionHandler: completion)

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
        return transferService.accounts(destinationUris: []) { result in
            do {
                let accounts = try result.get()
                let transferDestinations = accounts.first { $0.id == account.id }?.transferDestinations ?? []
                let filteredTransferDestinations = transferDestinations.filter { !($0.isMatchingMultipleDestinations ?? false) }
                let beneficiaries = filteredTransferDestinations.map { Beneficiary(account: account, transferDestination: $0) }
                completion(.success(beneficiaries))
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
        transferService.accounts(destinationUris: []) { result in
            do {
                let accounts = try result.get()
                let mappedTransferDestinations = accounts.reduce(into: [Account.ID: [Beneficiary]]()) { result, account in
                    let destinations = account.transferDestinations ?? []
                    let filteredTransferDestinations = destinations.filter { !($0.isMatchingMultipleDestinations ?? false) }
                    let beneficiaries = filteredTransferDestinations.map { Beneficiary(account: account, transferDestination: $0) }
                    result[account.id] = beneficiaries
                }
                completion(.success(mappedTransferDestinations))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
