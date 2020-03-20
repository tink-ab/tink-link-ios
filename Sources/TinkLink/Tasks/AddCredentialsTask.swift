import Foundation

/// A task that manages progress of adding a credential.
///
/// Use `CredentialsContext` to create a task.
public final class AddCredentialsTask: Identifiable {
    /// Indicates the state of a credentials being added.
    ///
    /// - Note: For some states there are actions which need to be performed on the credentials.
    public enum Status {
        /// Initial status
        case created

        /// When starting the authentication process
        case authenticating

        /// User has been successfully authenticated, now downloading data.
        case updating(status: String)

        /// Trigger for the client to prompt the user to fill out supplemental information.
        case awaitingSupplementalInformation(SupplementInformationTask)

        /// Trigger for the client to prompt the user to open the third party authentication flow
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
    }

    /// Error that the `AddCredentialsTask` can throw.
    public enum Error: Swift.Error {
        /// The authentication failed. The payload from the backend can be found in the associated value.
        case authenticationFailed(String)
        /// A temporary failure occurred. The payload from the backend can be found in the associated value.
        case temporaryFailure(String)
        /// A permanent failure occurred. The payload from the backend can be found in the associated value.
        case permanentFailure(String)
        /// The credentials already exists.
        case credentialsAlreadyExists(String)

        init?(addCredentialsError error: Swift.Error) {
            switch error {
            case ServiceError.alreadyExists(let payload):
                self = .credentialsAlreadyExists(payload)
            default:
                return nil
            }
        }
    }

    private var credentialsStatusPollingTask: CredentialStatusPollingTask?

    private(set) var credentials: Credentials?

    // MARK: - Evaluating Completion

    /// Cases to evaluate when credentials status changes.
    ///
    /// Use with `CredentialsContext.addCredentials(for:form:completionPredicate:progressHandler:completion:)` to set when add credentials task should call completion handler if successful.
    public struct CompletionPredicate {
        public enum SuccessPredicate {
            /// A predicate that indicates the credentials' status is `updating`.
            case updating
            /// A predicate that indicates the credentials' status is `updated`.
            case updated
        }

        public let successPredicate: SuccessPredicate
        public let shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool

        public init(successPredicate: SuccessPredicate, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool) {
            self.successPredicate = successPredicate
            self.shouldFailOnThirdPartyAppAuthenticationDownloadRequired = shouldFailOnThirdPartyAppAuthenticationDownloadRequired
        }
    }

    /// Predicate for when credentials task is completed.
    ///
    /// Task will execute it's completion handler if the credentials' status changes to match this predicate.
    public let completionPredicate: CompletionPredicate

    private let credentialsService: CredentialsService
    private let appUri: URL
    let progressHandler: (Status) -> Void
    let completion: (Result<Credentials, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credentialsService: CredentialsService, completionPredicate: CompletionPredicate, appUri: URL, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credentials, Swift.Error>) -> Void) {
        self.credentialsService = credentialsService
        self.completionPredicate = completionPredicate
        self.appUri = appUri
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving(_ credentials: Credentials) {
        self.credentials = credentials

        handleUpdate(for: .success(credentials))
        credentialsStatusPollingTask = CredentialStatusPollingTask(credentialsService: credentialsService, credentials: credentials) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        credentialsStatusPollingTask?.pollStatus()
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
                let supplementInformationTask = SupplementInformationTask(credentialsService: credentialsService, credentials: credentials) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialsStatusPollingTask = CredentialStatusPollingTask(credentialsService: self.credentialsService, credentials: credentials, updateHandler: self.handleUpdate)
                        self.credentialsStatusPollingTask?.pollStatus()
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
                let task = ThirdPartyAppAuthenticationTask(thirdPartyAppAuthentication: thirdPartyAppAuthentication, appUri: appUri) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialsStatusPollingTask = CredentialStatusPollingTask(credentialsService: self.credentialsService, credentials: credentials, updateHandler: self.handleUpdate)
                        self.credentialsStatusPollingTask?.pollStatus()
                    } catch {
                        let taskError = error as? ThirdPartyAppAuthenticationTask.Error
                        switch taskError {
                        case .downloadRequired where !self.completionPredicate.shouldFailOnThirdPartyAppAuthenticationDownloadRequired:
                            self.credentialsStatusPollingTask = CredentialStatusPollingTask(credentialsService: self.credentialsService, credentials: credentials, updateHandler: self.handleUpdate)
                            self.credentialsStatusPollingTask?.pollStatus()
                        default:
                            self.completion(.failure(error))
                        }
                    }
                }
                progressHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                if completionPredicate.successPredicate == .updating {
                    completion(.success(credentials))
                } else {
                    progressHandler(.updating(status: credentials.statusPayload))
                }
            case .updated:
                if completionPredicate.successPredicate == .updated {
                    completion(.success(credentials))
                }
            case .permanentError:
                completion(.failure(AddCredentialsTask.Error.permanentFailure(credentials.statusPayload)))
            case .temporaryError:
                completion(.failure(AddCredentialsTask.Error.temporaryFailure(credentials.statusPayload)))
            case .authenticationError:
                completion(.failure(AddCredentialsTask.Error.authenticationFailed(credentials.statusPayload)))
            case .disabled:
                fatalError("credentials shouldn't be disabled during creation.")
            case .sessionExpired:
                fatalError("Credential's session shouldn't expire during creation.")
            case .unknown:
                assertionFailure("Unknown credentials status!")
            }
        } catch {
            completion(.failure(error))
        }
    }
}
