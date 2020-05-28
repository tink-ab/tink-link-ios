import Foundation

/// An object that you use to access the user's accounts, beneficiaries and transfer functionality.
public final class TransferContext {
    private let tink: Tink
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    // MARK: - Creating a Context

    /// Creates a context to use for initiating transfers.
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
    /// You need to handle authentication changes in `authentication` to successfuly initiate a transfer.
    /// Also if needed, you can get the progress status change in `progress`, and present them accordingly.
    ///
    /// ```swift
    /// initiateTransferTask = transferContext.initiateTransfer(
    ///     fromAccountWithURI: sourceAccountURI,
    ///     toBeneficiaryWithURI: transferBeneficiaryURI,
    ///     amount: CurrencyDenominatedAmount(value: amount, currencyCode: balance.currencyCode),
    ///     message: .init(destination: message),
    ///     authentication: { task in
    ///         switch task {
    ///         case .awaitingSupplementalInformation(let task):
    ///             <#Present form for supplemental information task#>
    ///         case .awaitingThirdPartyAppAuthentication(let task):
    ///             <#Handle the third party app deep link URL#>
    ///          }
    ///     },
    ///     progress: { status in
    ///         <#Present the progress status change if needed#>
    ///     },
    ///     completion: { result in
    ///         <#Handle result#>
    ///     }
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - fromAccountWithURI: The transfer's source account URI.
    ///   - toBeneficiaryWithURI: The transfer's destination beneficiary URI.
    ///   - amount: The amount that should be transferred. It's `CurrencyCode` should be the same as the source account's currency.
    ///   - message: The message used for the transfer.
    ///   - authentication: Indicates the authentication task for initiate the transfer.
    ///   - progress: Optional, Indicates the state changes of initiating a transfer.
    ///   - completion: The block to execute when the transfer has been initiated successfuly or if it failed.
    ///   - result: A result representing either a transfer initiation receipt or an error.
    /// - Returns: The initiate transfer task.
    public func initiateTransfer(
        fromAccountWithURI: Account.URI,
        toBeneficiaryWithURI: Beneficiary.URI,
        amount: CurrencyDenominatedAmount,
        message: InitiateTransferTask.Message,
        authentication: @escaping (InitiateTransferTask.AuthenticationTask) -> Void,
        progress: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask {

        let task = InitiateTransferTask(
            transferService: transferService,
            credentialsService: credentialsService,
            appUri: tink.configuration.redirectURI,
            progressHandler: progress,
            authenticationHandler: authentication,
            completionHandler: completion
        )

        let transfer = Transfer(
            amount: amount.value,
            id: nil,
            credentialsID: nil,
            currency: amount.currencyCode,
            sourceMessage: message.source,
            destinationMessage: message.destination,
            dueDate: nil,
            destinationUri: toBeneficiaryWithURI.uri,
            sourceUri: fromAccountWithURI.uri
        )

        task.canceller = transferService.transfer(transfer: transfer, redirectURI: tink.configuration.redirectURI) { [weak task] result in
            do {
                let signableOperation = try result.get()
                task?.startObserving(signableOperation)
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }

    /// Initiate a transfer for the user.
    ///
    /// You need to handle authentication changes in `authentication` to successfuly initiate a transfer.
    /// Also if needed, you can get the progress status change in `progress`, and present them accordingly.
    ///
    /// ```swift
    /// initiateTransferTask = transferContext.initiateTransfer(
    ///     from: sourceAccount,
    ///     to: transferBeneficiary,
    ///     amount: CurrencyDenominatedAmount(value: amount, currencyCode: balance.currencyCode),
    ///     message: .init(destination: message),
    ///     authentication: { task in
    ///         switch task {
    ///         case .awaitingSupplementalInformation(let task):
    ///             <#Present form for supplemental information task#>
    ///         case .awaitingThirdPartyAppAuthentication(let task):
    ///             <#Handle the third party app deep link URL#>
    ///          }
    ///     },
    ///     progress: { status in
    ///         <#Present the progress status change if needed#>
    ///     },
    ///     completion: { result in
    ///         <#Handle result#>
    ///     }
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - from: The transfer's source account.
    ///   - to: The transfer's destination beneficiary.
    ///   - amount: The amount that should be transferred. It's `CurrencyCode` should be the same as the source account's currency.
    ///   - message: The message used for the transfer.
    ///   - authentication: Indicates the authentication task for initiate the transfer.
    ///   - progress: Optional, Indicates the state changes of initiating a transfer.
    ///   - completion: The block to execute when the transfer has been initiated successfuly or if it failed.
    ///   - result: A result representing either a transfer initiation receipt or an error.
    /// - Returns: The initiate transfer task.
    public func initiateTransfer(
        from source: Account,
        to destination: Beneficiary,
        amount: CurrencyDenominatedAmount,
        message: InitiateTransferTask.Message,
        authentication: @escaping (InitiateTransferTask.AuthenticationTask) -> Void,
        progress: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask {
        guard let source = Account.URI(account: source) else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let destination = Beneficiary.URI(beneficiary: destination) else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        return initiateTransfer(
            fromAccountWithURI: source,
            toBeneficiaryWithURI: destination,
            amount: amount,
            message: message,
            authentication: authentication,
            progress: progress,
            completion: completion
        )
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

    /// Fetches all transfer beneficiaries for all accounts.
    ///
    /// - Parameter completion: A result representing either a list of account ID and beneficiaries pair or an error.
    public func fetchBeneficiaries(completion: @escaping (Result<[Account.ID: [Beneficiary]], Error>) -> Void) -> RetryCancellable? {
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
