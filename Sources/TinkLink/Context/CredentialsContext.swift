import Foundation

/// An object that you use to access the user's credentials and supports the flow for adding credentials.
public final class CredentialsContext {
    private let redirectURI: URL
    private let service: CredentialsService
    private var credentialThirdPartyCallbackObserver: Any?
    private var thirdPartyCallbackCanceller: RetryCancellable?

    private var newlyAddedCredentials: [Provider.ID: Credentials] = [:]

    // MARK: - Creating a Credentials Context

    /// Creates a new CredentialsContext for the given Tink instance.
    ///
    /// - Parameter tink: Tink instance, defaults to `shared` if not provided.
    public convenience init(tink: Tink = .shared) {
        let service = tink.services.credentialsService
        self.init(tink: tink, credentialsService: service)
    }

    init(tink: Tink, credentialsService: CredentialsService) {
        self.redirectURI = tink.configuration.redirectURI
        self.service = credentialsService
        addStoreObservers()
    }

    private func addStoreObservers() {
        credentialThirdPartyCallbackObserver = NotificationCenter.default.addObserver(forName: .credentialThirdPartyCallback, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            if let userInfo = notification.userInfo as? [String: String] {
                var parameters = userInfo
                let stateParameterName = "state"
                guard let state = parameters.removeValue(forKey: stateParameterName) else { return }
                self.thirdPartyCallbackCanceller = self.service.thirdPartyCallback(
                    state: state,
                    parameters: parameters,
                    completion: { _ in }
                )
            }
        }
    }

    private func removeObservers() {
        credentialThirdPartyCallbackObserver = nil
    }

    deinit {
        removeObservers()
    }

    // MARK: - Adding Credentials

    /// Adds a credentials for the user.
    ///
    /// Required scopes:
    /// - credentials:write
    ///
    /// You need to handle status changes in `progressHandler` to successfuly add a credentials for some providers.
    ///
    ///     let addCredentialsTask = credentialsContext.add(for: provider, form: form, progressHandler: { status in
    ///         switch status {
    ///         case .awaitingSupplementalInformation(let supplementInformationTask):
    ///             <#Present form for supplemental information task#>
    ///         case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
    ///             <#Open third party app deep link URL#>
    ///         default:
    ///             break
    ///         }
    ///     }, completion: { result in
    ///         <#Handle result#>
    ///     }
    ///
    /// - Parameters:
    ///   - provider: The provider (financial institution) that the credentials is connected to.
    ///   - form: This is a form with fields from the Provider to which the credentials belongs to.
    ///   - refreshableItems: The data types to aggregate from the provider. Defaults to all types.
    ///   - completionPredicate: Predicate for when credentials task should complete.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credentials being added.
    ///   - completion: The block to execute when the credentials has been added successfuly or if it failed.
    ///   - result: Represents either a successfully added credentials or an error if adding the credentials failed.
    /// - Returns: The add credentials task.
    public func add(
        for provider: Provider,
        form: Form,
        refreshableItems: RefreshableItems = .all,
        completionPredicate: AddCredentialsTask.CompletionPredicate = .init(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: true),
        progressHandler: @escaping (_ status: AddCredentialsTask.Status) -> Void,
        authenticationHandler: @escaping AuthenticationTaskHandler,
        completion: @escaping (_ result: Result<Credentials, Error>) -> Void
    ) -> AddCredentialsTask {
        let refreshableItems = refreshableItems.supporting(providerCapabilities: provider.capabilities)

        let task = AddCredentialsTask(
            credentialsService: service,
            completionPredicate: completionPredicate,
            appUri: redirectURI,
            progressHandler: progressHandler,
            authenticationHandler: authenticationHandler, 
            completion: completion
        )

        if let newlyAddedCredentials = newlyAddedCredentials[provider.id] {
            task.callCanceller = service.update(id: newlyAddedCredentials.id, providerID: newlyAddedCredentials.providerID, appURI: redirectURI, callbackURI: nil, fields: form.makeFields()) { result in
                do {
                    let credentials = try result.get()
                    task.startObserving(credentials)
                } catch {
                    let mappedError = AddCredentialsTask.Error(addCredentialsError: error) ?? error
                    completion(.failure(mappedError))
                }
            }
        } else {
            task.callCanceller = service.create(providerID: provider.id, refreshableItems: refreshableItems, fields: form.makeFields(), appURI: redirectURI, callbackURI: nil) { [weak task, weak self] result in
                do {
                    let credential = try result.get()
                    self?.newlyAddedCredentials[provider.id] = credential
                    task?.startObserving(credential)
                } catch {
                    let mappedError = AddCredentialsTask.Error(addCredentialsError: error) ?? error
                    completion(.failure(mappedError))
                }
            }
        }
        return task
    }

    /// Fetch a list of the current user's credentials.
    ///
    /// Required scopes:
    /// - credentials:read
    ///
    /// - Parameter completion: The block to execute when the call is completed.
    /// - Parameter result: A result that either contain a list of the user credentials or an error if the fetch failed.
    @discardableResult
    public func fetchCredentialsList(completion: @escaping (_ result: Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        return service.credentialsList { result in
            do {
                let credentials = try result.get()
                let storedCredentials = credentials.sorted(by: { $0.id.value < $1.id.value })
                completion(.success(storedCredentials))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetch a credentials by ID.
    ///
    /// Required scopes:
    /// - credentials:read
    ///
    /// - Parameter id: The id of the credentials to fetch.
    /// - Parameter completion: The block to execute when the call is completed.
    /// - Parameter result: A result that either contains the credentials or an error if the fetch failed.
    @discardableResult
    public func fetchCredentials(with id: Credentials.ID, completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return service.credentials(id: id) { result in
            do {
                let credentials = try result.get()
                completion(.success(credentials))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Managing Credentials

    /// Refresh the user's credentials.
    ///
    /// Required scopes:
    /// - credentials:refresh
    ///
    /// - Parameters:
    ///   - authenticate: Force an authentication before the refresh, designed for open banking credentials. Defaults to false.
    ///   - refreshableItems: The data types to aggregate from the provider. Defaults to all types.
    ///   - shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Determines how the task handles the case when a user doesn't have the required authentication app installed.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credentials being refreshed.
    ///   - completion: The block to execute when the credentials has been refreshed successfuly or if it failed.
    ///   - result: A result that either contains the refreshed credentials or an error if the refresh failed.
    /// - Returns: The refresh credentials task.
    public func refresh(
        _ credentials: Credentials,
        authenticate: Bool = false,
        refreshableItems: RefreshableItems = .all,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: RefreshCredentialsTask.Status) -> Void,
        authenticationHandler: @escaping AuthenticationTaskHandler,
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> RefreshCredentialsTask {
        // TODO: Filter out refreshableItems not supported by provider capabilities.

        let task = RefreshCredentialsTask(credentials: credentials, credentialsService: service, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired, appUri: redirectURI, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completion: completion)

        task.callCanceller = service.refresh(id: credentials.id, authenticate: authenticate, refreshableItems: refreshableItems, optIn: false, completion: { result in
            switch result {
            case .success:
                task.startObserving()
            case .failure(let error):
                completion(.failure(error))
            }
        })

        return task
    }

    /// Update the user's credentials.
    ///
    /// Required scopes:
    /// - credentials:write
    ///
    /// - Parameters:
    ///   - credentials: Credentials that needs to be updated.
    ///   - form: This is a form with fields from the Provider to which the credentials belongs to.
    ///   - shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Determines how the task handles the case when a user doesn't have the required authentication app installed.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credentials being updated.
    ///   - completion: The block to execute when the credentials has been updated successfuly or if it failed.
    ///   - result: A result with either an updated credentials if the update succeeded or an error if failed.
    /// - Returns: The update credentials task.
    @discardableResult
    public func update(
        _ credentials: Credentials,
        form: Form? = nil,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: UpdateCredentialsTask.Status) -> Void,
        authenticationHandler: @escaping AuthenticationTaskHandler,
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> UpdateCredentialsTask {
        let task = UpdateCredentialsTask(
            credentials: credentials,
            credentialsService: service,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired,
            appUri: redirectURI,
            progressHandler: progressHandler,
            authenticationHandler: authenticationHandler,
            completion: completion
        )

        task.callCanceller = service.update(
            id: credentials.id,
            providerID: credentials.providerID,
            appURI: redirectURI,
            callbackURI: nil,
            fields: form?.makeFields() ?? [:],
            completion: { result in
                switch result {
                case .success:
                    task.startObserving()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )

        return task
    }

    /// Delete the user's credentials.
    ///
    /// Required scopes:
    /// - credentials:write
    ///
    /// - Parameters:
    ///   - credentials: The credentials to delete.
    ///   - completion: The block to execute when the credentials has been deleted successfuly or if it failed.
    ///   - result: A result representing that the delete succeeded or an error if failed.
    /// - Returns: A cancellation handler.
    @discardableResult
    public func delete(_ credentials: Credentials, completion: @escaping (_ result: Result<Void, Swift.Error>) -> Void) -> RetryCancellable? {
        return service.delete(id: credentials.id, completion: completion)
    }

    // MARK: - Authenticate Credentials

    /// Authenticate the user's `OPEN_BANKING` access type credentials.
    ///
    /// Required scopes:
    /// - credentials:refresh
    ///
    /// - Parameters:
    ///   - credentials: Credentials that needs to be authenticated.
    ///   - shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Determines how the task handles the case when a user doesn't have the required authentication app installed.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credentials being authenticated.
    ///   - completion: The block to execute when the credentials has been authenticated successfuly or if it failed.
    ///   - result: A result representing that the authentication succeeded or an error if failed.
    /// - Returns: The authenticate credentials task.
    public func authenticate(
        _ credentials: Credentials, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: AuthenticateCredentialsTask.Status) -> Void,
        authenticationHandler: @escaping AuthenticationTaskHandler,
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> AuthenticateCredentialsTask {
        let task = RefreshCredentialsTask(credentials: credentials, credentialsService: service, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired, appUri: redirectURI, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completion: completion)

        task.callCanceller = service.authenticate(id: credentials.id, completion: { result in
            switch result {
            case .success:
                task.startObserving()
            case .failure(let error):
                completion(.failure(error))
            }
        })

        return task
    }
}

extension Notification.Name {
    static let credentialThirdPartyCallback = Notification.Name("TinkLinkCredentialThirdPartyCallbackNotificationName")
}
