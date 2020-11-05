import Foundation

/// A task that manages progress of adding a beneficiary to an account.
///
/// Use `TransferContext` to create a task.
public final class AddBeneficiaryTask: Cancellable {
    // MARK: Types

    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>

    /// Indicates the state of a beneficiary being added.
    public enum Status {
        /// The adding beneficiary request has been sent.
        case requestSent
        /// The user needs to be authenticated.
        case authenticating
        /// The credentials are updating.
        case updating
    }

    /// Error that the `AddBeneficiaryTask` can throw.
    public enum Error: Swift.Error {
        /// The beneficiary was invalid.
        /// If you get this error, make sure that the parameters for `addBeneficiary` are correct.
        ///
        /// The payload from the backend can be found in the associated value.
        case invalidBeneficiary(String?)
        /// The authentication failed.
        ///
        /// The payload from the backend can be found in the associated value.
        case authenticationFailed(String?)
        /// The credentials are deleted.
        ///
        /// The payload from the backend can be found in the associated value.
        case credentialsDeleted(String?)
        /// The credentials session was expired.
        ///
        /// The payload from the backend can be found in the associated value.
        case credentialsSessionExpired(String?)
        /// The beneficiary could not be found.
        ///
        /// The payload from the backend can be found in the associated value.
        case notFound(String?)

        init?(_ error: Swift.Error) {
            switch error {
            case ServiceError.invalidArgument(let message):
                self = .invalidBeneficiary(message)
            case ServiceError.notFound(let message):
                self = .notFound(message)
            default:
                return nil
            }
        }
    }

    /// Determines how the task handles the case when a user doesn't have the required authentication app installed.
    public let shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool

    var retryInterval: TimeInterval = 1.0

    // MARK: Dependencies

    private let beneficiaryService: BeneficiaryService
    private let credentialsService: CredentialsService

    // MARK: Properties

    private let appUri: URL
    private let ownerAccountID: Account.ID
    private let ownerAccountCredentialsID: Credentials.ID
    private let name: String
    private let accountNumberType: String
    private let accountNumber: String
    private var fetchedCredentials: Credentials?
    private let progressHandler: (Status) -> Void
    private let authenticationHandler: (AuthenticationTask) -> Void
    private let completionHandler: (Result<Void, Swift.Error>) -> Void

    // MARK: Tasks

    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var supplementInformationTask: SupplementInformationTask?
    private var thirdPartyAppAuthenticationTask: ThirdPartyAppAuthenticationTask?

    var callCanceller: Cancellable?
    private var fetchBeneficiariesCanceller: Cancellable?

    // MARK: State

    private var isCancelled = false
    private var didComplete = false

    // MARK: Initializers

    init(
        beneficiaryService: BeneficiaryService,
        credentialsService: CredentialsService,
        appUri: URL,
        ownerAccountID: Account.ID,
        ownerAccountCredentialsID: Credentials.ID,
        name: String,
        accountNumberType: String,
        accountNumber: String,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool,
        progressHandler: @escaping (Status) -> Void,
        authenticationHandler: @escaping (AuthenticationTask) -> Void,
        completionHandler: @escaping (Result<Void, Swift.Error>) -> Void
    ) {
        self.beneficiaryService = beneficiaryService
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.ownerAccountID = ownerAccountID
        self.ownerAccountCredentialsID = ownerAccountCredentialsID
        self.name = name
        self.accountNumberType = accountNumberType
        self.accountNumber = accountNumber
        self.shouldFailOnThirdPartyAppAuthenticationDownloadRequired = shouldFailOnThirdPartyAppAuthenticationDownloadRequired
        self.progressHandler = progressHandler
        self.authenticationHandler = authenticationHandler
        self.completionHandler = completionHandler
    }
}

// MARK: - Task Lifecycle

extension AddBeneficiaryTask {
    func start() {
        callCanceller = credentialsService.credentials(id: ownerAccountCredentialsID) { [weak self] result in
            do {
                self?.fetchedCredentials = try result.get()
                self?.createBeneficiary()
            } catch {
                self?.complete(with: .failure(Error(error) ?? error))
            }
        }
    }

    private func createBeneficiary() {
        callCanceller = beneficiaryService.create(
            accountNumberKind: .init(accountNumberType),
            accountNumber: accountNumber,
            name: name,
            ownerAccountID: ownerAccountID,
            credentialsID: ownerAccountCredentialsID,
            appURI: appUri
        ) { [weak self, credentialsID = ownerAccountCredentialsID] result in
            do {
                try result.get()
                self?.progressHandler(.requestSent)
                self?.startObservingCredentials(id: credentialsID)
            } catch {
                self?.complete(with: .failure(Error(error) ?? error))
            }
        }
    }

    /// Cancel the task.
    public func cancel() {
        callCanceller?.cancel()
        fetchBeneficiariesCanceller?.cancel()
        isCancelled = true
    }
}

// MARK: - Credentials Observing

extension AddBeneficiaryTask {
    private func startObservingCredentials(id: Credentials.ID) {
        if isCancelled { return }

        credentialsStatusPollingTask = CredentialsStatusPollingTask(
            id: id,
            initialValue: fetchedCredentials,
            request: credentialsService.credentials,
            predicate: { old, new in
                guard let oldStatusUpdated = old.statusUpdated else {
                    return new.statusUpdated != nil || old.status != new.status
                }

                guard let newStatusUpdated = new.statusUpdated else {
                    return old.status != new.status
                }

                return oldStatusUpdated < newStatusUpdated || old.status != new.status
            },
            updateHandler: { [weak self] result in
                self?.handleUpdate(for: result)
            }
        )
        credentialsStatusPollingTask?.retryInterval = retryInterval
        credentialsStatusPollingTask?.startPolling()
    }

    private func handleUpdate(for result: Result<Credentials, Swift.Error>) {
        if isCancelled { return }
        do {
            let credentials = try result.get()
            try handleCredentials(credentials)
        } catch {
            complete(with: .failure(error))
        }
    }

    private func handleCredentials(_ credentials: Credentials) throws {
        switch credentials.status {
        case .created:
            break
        case .authenticating:
            progressHandler(.authenticating)
        case .awaitingSupplementalInformation:
            credentialsStatusPollingTask?.stopPolling()
            let task = SupplementInformationTask(
                credentialsService: credentialsService,
                credentials: credentials
            ) { [weak self] result in
                do {
                    try result.get()
                    self?.credentialsStatusPollingTask?.startPolling()
                } catch {
                    self?.complete(with: .failure(error))
                }
                self?.supplementInformationTask = nil
            }
            supplementInformationTask = task
            authenticationHandler(.awaitingSupplementalInformation(task))
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication), .awaitingMobileBankIDAuthentication(let thirdPartyAppAuthentication):
            credentialsStatusPollingTask?.stopPolling()
            let task = ThirdPartyAppAuthenticationTask(
                credentials: credentials,
                thirdPartyAppAuthentication: thirdPartyAppAuthentication,
                appUri: appUri,
                credentialsService: credentialsService,
                shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired
            ) { [weak self] result in
                do {
                    try result.get()
                    self?.credentialsStatusPollingTask?.startPolling()
                } catch {
                    self?.complete(with: .failure(error))
                }
                self?.thirdPartyAppAuthenticationTask = nil
            }
            thirdPartyAppAuthenticationTask = task
            authenticationHandler(.awaitingThirdPartyAppAuthentication(task))
        case .updating:
            // Need to keep polling here, updated is the state when the authentication is done.
            progressHandler(.updating)
        case .updated:
            complete(with: .success(credentials))
        case .permanentError:
            throw Error.authenticationFailed(credentials.statusPayload)
        case .temporaryError:
            throw Error.authenticationFailed(credentials.statusPayload)
        case .authenticationError:
            throw Error.authenticationFailed(credentials.statusPayload)
        case .deleted:
            throw Error.credentialsDeleted(credentials.statusPayload)
        case .sessionExpired:
            throw Error.credentialsSessionExpired(credentials.statusPayload)
        case .unknown:
            assertionFailure("Unknown credentials status!")
        @unknown default:
            assertionFailure("Unknown credentials status!")
        }
    }
}

// MARK: - Task Completion

extension AddBeneficiaryTask {
    private func complete(with result: Result<Credentials, Swift.Error>) {
        if didComplete { return }
        defer { didComplete = true }

        credentialsStatusPollingTask?.stopPolling()
        do {
            _ = try result.get()
            completionHandler(.success)
        } catch {
            completionHandler(.failure(error))
        }
    }
}
