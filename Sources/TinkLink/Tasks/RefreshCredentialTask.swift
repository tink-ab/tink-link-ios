import Foundation

/// A task that manages progress of refreshing a credential.
///
/// Use `CredentialContext` to create a task.
public final class RefreshCredentialTask: Identifiable {
    /// Indicates the state of a credentials being refreshed.
    ///
    /// - Note: For some states there are actions which need to be performed on the credentials.
    public enum Status {
        /// When the credentials has just been created
        case created

        /// When starting the authentication process
        case authenticating

        /// User has been successfully authenticated, now downloading data.
        case updating(status: String)

        /// Trigger for the client to prompt the user to fill out supplemental information.
        case awaitingSupplementalInformation(SupplementInformationTask)

        /// Trigger for the client to prompt the user to open the third party authentication flow
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)

        /// The session has expired.
        case sessionExpired

        /// The status has been updated.
        case updated

        /// The refresh error.
        case error(Error)
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

    public private(set) var credentials: Credentials

    private let credentialService: CredentialsService
    private let appUri: URL
    let progressHandler: (Status) -> Void
    let completion: (Result<Credentials, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credentials: Credentials, credentialService: CredentialsService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool, appUri: URL, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credentials, Swift.Error>) -> Void) {
        self.credentials = credentials
        self.credentialService = credentialService
        self.appUri = appUri
        self.progressHandler = progressHandler
        self.shouldFailOnThirdPartyAppAuthenticationDownloadRequired = shouldFailOnThirdPartyAppAuthenticationDownloadRequired
        self.completion = completion
    }

    func startObserving() {
        credentialStatusPollingTask = CredentialsListStatusPollingTask(
            credentialService: credentialService,
            credentials: [credentials],
            updateHandler: { [weak self] result in self?.handleUpdate(for: result) },
            completion: { [weak self] result in
                guard let self = self else { return }
                self.completion(result.map { $0.first ?? self.credentials })
            }
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

    private func handleUpdate(for result: Result<Credentials, Swift.Error>) {
        do {
            let credentials = try result.get()
            switch credentials.status {
            case .created:
                progressHandler(.created)
            case .authenticating:
                progressHandler(.authenticating)
            case .awaitingSupplementalInformation:
                credentialStatusPollingTask?.pausePolling()
                let supplementInformationTask = SupplementInformationTask(credentialsService: credentialService, credentials: credentials) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask?.continuePolling()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                guard let thirdPartyAppAuthentication = credentials.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
                }
                credentialStatusPollingTask?.pausePolling()
                let task = ThirdPartyAppAuthenticationTask(credentials: credentials, thirdPartyAppAuthentication: thirdPartyAppAuthentication, appUri: appUri, credentialsService: credentialService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask?.continuePolling()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                progressHandler(.updating(status: credentials.statusPayload))
            case .updated:
                progressHandler(.updated)
            case .sessionExpired:
                progressHandler(.sessionExpired)
            case .authenticationError:
                throw Error.authenticationFailed
            case .permanentError:
                throw Error.permanentFailure
            case .temporaryError:
                throw Error.temporaryFailure
            case .disabled:
                fatalError("credentials shouldn't be disabled during creation.")
            case .unknown:
                assertionFailure("Unknown credentials status!")
            }
        } catch {
            completion(.failure(error))
        }
    }
}
