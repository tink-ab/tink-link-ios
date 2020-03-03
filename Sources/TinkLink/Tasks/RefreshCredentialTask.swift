import Foundation

/// A task that manages progress of refreshing a credential.
///
/// Use `CredentialContext` to create a task.
public final class RefreshCredentialTask: Identifiable {
    /// Indicates the state of a credential being refreshed.
    ///
    /// - Note: For some states there are actions which need to be performed on the credentials.
    public enum Status {
        /// When the credential has just been created
        case created(credential: Credential)

        /// When starting the authentication process
        case authenticating(credential: Credential)

        /// User has been successfully authenticated, now downloading data.
        case updating(credential: Credential, status: String)

        /// Trigger for the client to prompt the user to fill out supplemental information.
        case awaitingSupplementalInformation(task: SupplementInformationTask)

        /// Trigger for the client to prompt the user to open the third party authentication flow
        case awaitingThirdPartyAppAuthentication(credential: Credential, task: ThirdPartyAppAuthenticationTask)

        /// The session has expired.
        case sessionExpired(credential: Credential)

        /// The status has been updated.
        case updated(credential: Credential)

        /// The refresh error.
        case error(credential: Credential, error: Error)
    }

    /// Error that the `RefreshCredentialTask` can throw.
    public enum Error: Swift.Error {
        /// The authentication failed.
        case authenticationFailed
        /// A temporary failure occurred.
        case temporaryFailure
        /// A permanent failure occurred.
        case permanentFailure
    }

    // MARK: - Retrieving Failure Requirements

    /// Determines how the task handles the case when a user doesn't have the required authentication app installed.
    public let shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool

    private var credentialStatusPollingTask: CredentialsListStatusPollingTask?

    // MARK: - Getting the Credentials

    public private(set) var credentials: [Credential]

    private let credentialService: CredentialService
    let progressHandler: (Status) -> Void
    let completion: (Result<[Credential], Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credentials: [Credential], credentialService: CredentialService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<[Credential], Swift.Error>) -> Void) {
        self.credentials = credentials
        self.credentialService = credentialService
        self.progressHandler = progressHandler
        self.shouldFailOnThirdPartyAppAuthenticationDownloadRequired = shouldFailOnThirdPartyAppAuthenticationDownloadRequired
        self.completion = completion
    }

    func startObserving() {
        credentialStatusPollingTask = CredentialsListStatusPollingTask(
            credentialService: credentialService,
            credentials: credentials,
            updateHandler: { [weak self] result in self?.handleUpdate(for: result) },
            completion: completion
        )

        credentialStatusPollingTask?.pollStatus()
        // Set the callCanceller to cancel the polling
        callCanceller = credentialStatusPollingTask?.callRetryCancellable
    }

    // MARK: - Controlling the Task

    /// Cancel the task.
    public func cancel() {
        callCanceller?.cancel()
    }

    private func handleUpdate(for result: Result<Credential, Swift.Error>) {
        do {
            let credential = try result.get()
            switch credential.status {
            case .created:
                progressHandler(.created(credential: credential))
            case .authenticating:
                progressHandler(.authenticating(credential: credential))
            case .awaitingSupplementalInformation:
                credentialStatusPollingTask?.pausePolling()
                let supplementInformationTask = SupplementInformationTask(credentialService: credentialService, credential: credential) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask?.continuePolling()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingSupplementalInformation(task: supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                guard let thirdPartyAppAuthentication = credential.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
                }
                credentialStatusPollingTask?.pausePolling()
                let task = ThirdPartyAppAuthenticationTask(credential: credential, thirdPartyAppAuthentication: thirdPartyAppAuthentication, credentialService: credentialService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask?.continuePolling()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingThirdPartyAppAuthentication(credential: credential, task: task))
            case .updating:
                progressHandler(.updating(credential: credential, status: credential.statusPayload))
            case .updated:
                progressHandler(.updated(credential: credential))
            case .sessionExpired:
                progressHandler(.sessionExpired(credential: credential))
            case .authenticationError:
                progressHandler(.error(credential: credential, error: .authenticationFailed))
            case .permanentError:
                progressHandler(.error(credential: credential, error: .permanentFailure))
            case .temporaryError:
                progressHandler(.error(credential: credential, error: .temporaryFailure))
            case .disabled:
                fatalError("Credential shouldn't be disabled during creation.")
            case .unknown:
                assertionFailure("Unknown credential status!")
            }
        } catch {
            completion(.failure(error))
        }
    }
}
