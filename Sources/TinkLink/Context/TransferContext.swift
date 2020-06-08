import Foundation

/// An object that you use to initiate transfers and access the user's accounts and beneficiaries.
public final class TransferContext {
    private let tink: Tink
    private let transferService: TransferService
    private let credentialsService: CredentialsService
    private let providerService: ProviderService

    // MARK: - Creating a Context

    /// Creates a context to use for initiating transfers.
    ///
    /// - Parameter tink: Tink instance. Will use the shared instance if nothing is provided.
    public convenience init(tink: Tink = .shared) {
        let transferService = RESTTransferService(client: tink.client)
        let credentialsService = RESTCredentialsService(client: tink.client)
        let providerService = RESTProviderService(client: tink.client)
        self.init(tink: tink, transferService: transferService, credentialsService: credentialsService, providerService: providerService)
    }

    init(tink: Tink, transferService: TransferService, credentialsService: CredentialsService, providerService: ProviderService) {
        self.tink = tink
        self.transferService = transferService
        self.credentialsService = credentialsService
        self.providerService = providerService
    }

    // MARK: - Initiate Transfer

    /// Initiate a transfer for the user.
    ///
    /// Required scopes:
    ///   - transfer:execute
    ///
    /// You need to handle authentication changes in `authentication` to successfuly initiate a transfer.
    /// If needed, you can get the progress status change in `progress`, and present them accordingly.
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
    ///   - amount: The amount that should be transferred. Its `CurrencyCode` should be the same as the source account's currency.
    ///   - message: The message used for the transfer.
    ///   - authentication: Indicates the authentication task for initiating a transfer.
    ///   - task: Represents an authentication task that needs to be completed by the user.
    ///   - progress: Optional, indicates the state changes of initiating a transfer.
    ///   - status: Indicates the status of the transfer initiation.
    ///   - completion: The block to execute when the transfer has been initiated successfuly or if it failed.
    ///   - result: A result representing either a transfer initiation receipt or an error.
    /// - Returns: The initiate transfer task.
    @available(*, deprecated, message: "Use the initiateTransfer(from:to:amount:message:authentication:progress:completion) method with a `BeneficiaryAccount` instead.")
    public func initiateTransfer(
        fromAccountWithURI: Account.URI,
        toBeneficiaryWithURI: Beneficiary.URI,
        amount: CurrencyDenominatedAmount,
        message: InitiateTransferTask.Message,
        authentication: @escaping (_ task: AuthenticationTask) -> Void,
        progress: @escaping (_ status: InitiateTransferTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<InitiateTransferTask.Receipt, Error>) -> Void
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
    /// Required scopes:
    ///   - transfer:execute
    ///
    /// You need to handle authentication changes in `authentication` to successfuly initiate a transfer.
    /// If needed, you can get the progress status change in `progress`, and present them accordingly.
    ///
    /// ```swift
    /// initiateTransferTask = transferContext.initiateTransfer(
    ///     from: account,
    ///     to: beneficiary,
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
    ///   - amount: The amount that should be transferred. Its `CurrencyCode` should be the same as the source account's currency.
    ///   - message: The message used for the transfer.
    ///   - authentication: Indicates the authentication task for initiating a transfer.
    ///   - task: Represents an authentication task that needs to be completed by the user.
    ///   - progress: Optional, indicates the state changes of initiating a transfer.
    ///   - status: Indicates the status of the transfer initiation.
    ///   - completion: The block to execute when the transfer has been initiated successfuly or if it failed.
    ///   - result: A result representing either a transfer initiation receipt or an error.
    /// - Returns: The initiate transfer task.
    public func initiateTransfer(
        from account: Account,
        to beneficiary: AccountNumberRepresentable,
        amount: CurrencyDenominatedAmount,
        message: InitiateTransferTask.Message,
        authentication: @escaping (_ task: AuthenticationTask) -> Void,
        progress: @escaping (_ status: InitiateTransferTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask {
        guard let sourceURI = Account.URI(account: account) else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let beneficiaryURI = beneficiary.uri else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

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
            destinationUri: beneficiaryURI.absoluteString,
            sourceUri: sourceURI.value
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

    // MARK: - Fetching Accounts

    /// Fetch all accounts of the user that are suitable to pick as the source of a transfer.
    ///
    /// Required scopes:
    ///   - transfer:read
    ///
    /// - Parameter completion: A result representing either a list of accounts or an error.
    @discardableResult
    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    // MARK: - Fetching Beneficiaries

    /// Fetch beneficiaries for a specific account of the user.
    ///
    /// - Parameter account: Account for beneficiaries to fetch
    /// - Parameter completion: A result representing either a list of beneficiaries or an error.
    @discardableResult
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
    /// Required scopes:
    /// - beneficiaries:read
    /// 
    /// The result list may include duplicate beneficiaries for different source accounts.
    /// You can group the list by account id as follow:
    ///
    /// ```swift
    /// let groupedBeneficiariesByAccountID = Dictionary(grouping: fetchedBeneficiaries, by: \.ownerAccountID)
    /// ```
    ///
    /// - Parameter completion: A result representing either a list of beneficiaries or an error.
    @discardableResult
    public func fetchBeneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        return transferService.beneficiaries(completion: completion)
    }

    // MARK: - Adding Beneficiaries

    /// Initiate the request for adding a beneficiary to the user's account.
    ///
    /// Required scopes:
    /// - beneficiaries:write
    ///
    /// You need to handle authentication changes in `authentication` to successfuly initiate an add beneficiary request.
    /// If needed, you can get the progress status change in `progress`, and present them accordingly.
    ///
    /// ```swift
    /// task = transferContext.addBeneficiary(
    ///     account: <#BeneficiaryAccount#>,
    ///     name: <#String#>,
    ///     to: <#Account#>,
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
    /// - Note: You need to retain the returned task until the add beneficiary request has completed.
    ///
    /// - Parameters:
    ///   - account: The account for this beneficiary.
    ///   - name: The name for this beneficiary.
    ///   - to: The account that the beneficiary should be added to.
    ///   - credentials: Optional, the `Credentials` used to add the beneficiary. Note that you can use different credentials than the account belongs to. This functionality exists to support the case where you may have two credentials for one financial institution, due to PSD2 regulations. If `nil` the beneficiary will be added to the credentials of the account.
    ///   - authentication: Indicates the authentication task for adding a beneficiary.
    ///   - task: Represents an authentication task that needs to be completed by the user.
    ///   - progress: Optional, indicates the state changes of adding a beneficiary.
    ///   - status: Indicates the status of the beneficiary being added.
    ///   - completion: The block to execute when the adding beneficiary has been initiated successfuly or if it failed.
    ///   - result: A result representing either an adding beneficiary initiation success or an error.
    /// - Returns: The initiate transfer task.
    public func addBeneficiary(
        account beneficiaryAccount: BeneficiaryAccount,
        name: String,
        to ownerAccount: Account,
        credentials: Credentials? = nil,
        authentication: @escaping (_ task: AuthenticationTask) -> Void,
        progress: @escaping (_ status: AddBeneficiaryTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<Void, Error>) -> Void
    ) -> AddBeneficiaryTask {
        let task = AddBeneficiaryTask(
            transferService: transferService,
            credentialsService: credentialsService,
            appUri: tink.configuration.redirectURI,
            ownerAccountID: ownerAccount.id,
            ownerAccountCredentialsID: credentials?.id ?? ownerAccount.credentialsID,
            name: name,
            accountNumberType: beneficiaryAccount.accountNumberKind.value,
            accountNumber: beneficiaryAccount.accountNumber,
            progressHandler: progress,
            authenticationHandler: authentication,
            completionHandler: completion
        )

        task.start()

        return task
    }

    /// Initiate the request for adding a beneficiary to the user's account.
    ///
    /// Required scopes:
    /// - beneficiaries:write
    ///
    /// You need to handle authentication changes in `authentication` to successfuly initiate an add beneficiary request.
    /// If needed, you can get the progress status change in `progress`, and present them accordingly.
    ///
    /// ```swift
    /// task = transferContext.addBeneficiary(
    ///     account: <#BeneficiaryAccount#>,
    ///     name: <#String#>,
    ///     toAccountWithID: <#Account.ID#>
    ///     onCredentialsWithID: <#Credentials.ID#>,
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
    /// - Note: You need to retain the returned task until the add beneficiary request has completed.
    ///
    /// - Parameters:
    ///   - account: The account for this beneficiary.
    ///   - name: The name for this beneficiary.
    ///   - toAccountWithID: The source account ID for adding a beneficiary.
    ///   - onCredentialsWithID: The ID of the `Credentials` used to add the beneficiary. Note that you can send in a different ID here than the credentials ID to which the account belongs. This functionality exists to support the case where you may have two credentials for one financial institution, due to PSD2 regulations.
    ///   - authentication: Indicates the authentication task for adding a beneficiary.
    ///   - task: Represents an authentication task that needs to be completed by the user.
    ///   - progress: Optional, indicates the state changes of adding a beneficiary.
    ///   - status: Indicates the status of the beneficiary being added.
    ///   - completion: The block to execute when the adding beneficiary has been initiated successfuly or if it failed.
    ///   - result: A result representing either an adding beneficiary initiation success or an error.
    /// - Returns: The initiate transfer task.
    public func addBeneficiary(
        account beneficiaryAccount: BeneficiaryAccount,
        name: String,
        toAccountWithID ownerAccountID: Account.ID,
        onCredentialsWithID credentialsID: Credentials.ID,
        authentication: @escaping (_ task: AuthenticationTask) -> Void,
        progress: @escaping (_ status: AddBeneficiaryTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<Void, Error>) -> Void
    ) -> AddBeneficiaryTask {
        let task = AddBeneficiaryTask(
            transferService: transferService,
            credentialsService: credentialsService,
            appUri: tink.configuration.redirectURI,
            ownerAccountID: ownerAccountID,
            ownerAccountCredentialsID: credentialsID,
            name: name,
            accountNumberType: beneficiaryAccount.accountNumberKind.value,
            accountNumber: beneficiaryAccount.accountNumber,
            progressHandler: progress,
            authenticationHandler: authentication,
            completionHandler: completion
        )

        task.start()

        return task
    }

    // MARK: - Find all credentials that are capable of adding a beneficiary.

    /// This functionality exists to support the case when a user has two credentials for one financial institution due to PSD2 regulations.
    /// Use this helper function to find the credentials that has the capability to add beneficiaries.
    /// - Parameters:
    ///   - to: The account that the beneficiary should be added to.
    ///   - credentialsList: The user's existing credentials list.
    ///   - providerList: The available provider list.
    /// - Returns: The credentials list that suitable for adding the beneficiary. Returns an empty array if no credentials are suitable for adding a beneficiary with.
    public func credentialsListCapableOfAddingBeneficiaries(to account: Account, credentialsList: [Credentials], providerList: [Provider]) -> [Credentials] {
        let filteredProviders = providerList.filter ({ $0.financialInstitution.id == account.financialInstitutionID && $0.capabilities.contains(.createBeneficiaries) })
        return credentialsList.filter { credentials in
            filteredProviders.contains { credentials.providerID == $0.id }
        }
    }

    /// Use this helper function to find the credentials that has the capability to add beneficiaries.
    ///
    /// Required scopes:
    /// - credentials:read
    ///
    /// This functionality exists to support the case when a user has two credentials for one financial institution due to PSD2 regulations.
    /// - Parameters:
    ///   - to: The account that the beneficiary should be added to.
    ///   - completion: A closure that's called with the result containing either the credentials or an error. Contains an empty array if no credentials are suitable for adding a beneficiary with.
    /// - Returns: A cancellation handle.
    @discardableResult
    public func fetchCredentialsListCapableOfAddingBeneficiaries(to account: Account, completion: @escaping (Result<[Credentials], Error>) -> Void) -> Cancellable {
        let group = DispatchGroup()

        var credentialsList: [Credentials] = []
        var providers: [Provider] = []
        var errors: [Error] = []

        group.enter()
        // TODO: Use returned cancellable for cancellation
        _ = credentialsService.credentialsList { result in
            do {
                credentialsList = try result.get()
            } catch {
                errors.append(error)
            }
            group.leave()
        }

        group.enter()
        // TODO: Use returned cancellable for cancellation
        _ = providerService.providers(id: nil, capabilities: .createBeneficiaries, includeTestProviders: true) { result in
            do {
                providers = try result.get()
            } catch {
                errors.append(error)
            }
            group.leave()
        }

        let workItem = DispatchWorkItem {
            if let error = errors.first {
                completion(.failure(error))
            } else {
                let filteredProviders = providers.filter { $0.financialInstitution.id == account.financialInstitutionID && $0.capabilities.contains(.createBeneficiaries) }
                let credentialsByProviderID = Dictionary(grouping: credentialsList, by: \.providerID)
                let capableCredentialsList = filteredProviders.flatMap { credentialsByProviderID[$0.id] ?? [] }
                completion(.success(capableCredentialsList))
            }
        }

        group.notify(queue: .main, work: workItem)

        return workItem
    }
}
