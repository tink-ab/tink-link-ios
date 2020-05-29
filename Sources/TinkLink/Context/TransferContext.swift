import Foundation

/// An object that you use to initiate transfers and access the user's accounts and beneficiaries.
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
    /// - Note: You need to retain the returned task until the transfer has completed.
    ///
    /// - Parameters:
    ///   - fromAccountWithURI: The URI for the source account of the transfer.
    ///   - toBeneficiaryWithURI: The URI of the beneficiary the transfer is sent to.
    ///   - amount: The amount that should be transferred. It's `CurrencyCode` should be the same as the source account's currency.
    ///   - message: The message used for the transfer.
    ///   - authentication: Indicates the authentication task for initiating a transfer.
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
            destinationUri: toBeneficiaryWithURI.value,
            sourceUri: fromAccountWithURI.value
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
    /// - Note: You need to retain the returned task until the transfer has completed.
    ///
    /// - Parameters:
    ///   - from: The source account of this transfer.
    ///   - to: The beneficiary of this transfer.
    ///   - amount: The amount that should be transferred. It's `CurrencyCode` should be the same as the source account's currency.
    ///   - message: The message used for the transfer.
    ///   - authentication: Indicates the authentication task for initiating a transfer.
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
        guard let sourceURI = Account.URI(account: source) else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let beneficiaryURI = Beneficiary.URI(beneficiary: destination) else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        return initiateTransfer(
            fromAccountWithURI: sourceURI,
            toBeneficiaryWithURI: beneficiaryURI,
            amount: amount,
            message: message,
            authentication: authentication,
            progress: progress,
            completion: completion
        )
    }

    // MARK: - Fetching Accounts

    /// Fetch all accounts of the user that are suitable to pick as the source of a transfer.
    ///
    /// - Parameter completion: A result representing either a list of accounts or an error.
    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    // MARK: - Fetching Beneficiaries

    /// Fetch beneficiaries for a specific account of the user.
    ///
    /// - Parameter account: Account for beneficiaries to fetch
    /// - Parameter completion: A result representing either a list of beneficiaries or an error.
    public func fetchBeneficiaries(for account: Account, completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        return transferService.beneficiaries { result in
            do {
                let beneficiaries = try result.get()
                let filteredBeneficiaries = beneficiaries.filter { $0.ownerAccountID == account.id }
                completion(.success(filteredBeneficiaries))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetch all beneficiaries of the user.
    ///
    /// The beneficiaries will be grouped by account id.
    ///
    /// - Parameter completion: A result representing either a list of account ID and beneficiaries pair or an error.
    public func fetchBeneficiaries(completion: @escaping (Result<[Account.ID: [Beneficiary]], Error>) -> Void) -> RetryCancellable? {
        transferService.beneficiaries() { result in
            do {
                let beneficiaries = try result.get()
                let groupedBeneficiariesByAccountID = Dictionary(grouping: beneficiaries, by: \.ownerAccountID)
                completion(.success(groupedBeneficiariesByAccountID))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
