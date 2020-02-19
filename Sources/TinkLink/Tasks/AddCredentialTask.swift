import Foundation

/// A task that manages progress of adding a credential.
///
/// Use `CredentialContext` to create a task.
public final class AddCredentialTask: Identifiable {
    /// Indicates the state of a credential being added.
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

    /// Error that the `AddCredentialTask` can throw.
    public enum Error: Swift.Error {
        /// The authentication failed.
        case authenticationFailed
        /// A temporary failure occurred.
        case temporaryFailure
        /// A permanent failure occurred.
        case permanentFailure
        /// An unknown error. More details can be found in the associated Error value.
        case other(Swift.Error)

        init(error: Swift.Error) {
            if let credentialError = error as? AddCredentialTask.Error {
                self = credentialError
            } else {
                self = .other(error)
            }
        }
    }

    private var credentialStatusPollingTask: CredentialStatusPollingTask?

    private(set) var credential: Credential?

    // MARK: - Evaluating Completion

    /// Cases to evaluate when credential status changes.
    ///
    /// Use with `CredentialContext.addCredential(for:form:completionPredicate:progressHandler:completion:)` to set when add credential task should call completion handler if successful.
    public struct CompletionPredicate {
        public enum SuccessPredicate {
            /// A predicate that indicates the credential's status is `updating`.
            case updating
            /// A predicate that indicates the credential's status is `updated`.
            case updated
        }

        public let successPredicate: SuccessPredicate
        public let shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool

        public init(successPredicate: SuccessPredicate, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool) {
            self.successPredicate = successPredicate
            self.shouldFailOnThirdPartyAppAuthenticationDownloadRequired = shouldFailOnThirdPartyAppAuthenticationDownloadRequired
        }
    }

    /// Predicate for when credential task is completed.
    ///
    /// Task will execute it's completion handler if the credential's status changes to match this predicate.
    public let completionPredicate: CompletionPredicate

    private let credentialService: CredentialService
    let progressHandler: (Status) -> Void
    let completion: (Result<Credential, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credentialService: CredentialService, completionPredicate: CompletionPredicate, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credential, Swift.Error>) -> Void) {
        self.credentialService = credentialService
        self.completionPredicate = completionPredicate
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving(_ credential: Credential) {
        self.credential = credential

        handleUpdate(for: .success(credential))
        credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: credentialService, credential: credential) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        credentialStatusPollingTask?.pollStatus()
    }

    // MARK: - Controlling the Task

    /// Cancel the task.
    public func cancel() {
        callCanceller?.cancel()
    }

    private func handleUpdate(for result: Result<Credential, Error>) {
        do {
            let credential = try result.get()
            switch credential.status {
            case .created:
                progressHandler(.created)
            case .authenticating:
                progressHandler(.authenticating)
            case .awaitingSupplementalInformation:
                let supplementInformationTask = SupplementInformationTask(credentialService: credentialService, credential: credential) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: self.credentialService, credential: credential, updateHandler: self.handleUpdate)
                        self.credentialStatusPollingTask?.pollStatus()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                guard let thirdPartyAppAuthentication = credential.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
                }
                let task = ThirdPartyAppAuthenticationTask(thirdPartyAppAuthentication: thirdPartyAppAuthentication) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: self.credentialService, credential: credential, updateHandler: self.handleUpdate)
                        self.credentialStatusPollingTask?.pollStatus()
                    } catch {
                        let taskError = error as? ThirdPartyAppAuthenticationTask.Error
                        switch taskError {
                        case .downloadRequired where !self.completionPredicate.shouldFailOnThirdPartyAppAuthenticationDownloadRequired:
                            self.credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: self.credentialService, credential: credential, updateHandler: self.handleUpdate)
                            self.credentialStatusPollingTask?.pollStatus()
                        default:
                            self.completion(.failure(error))
                        }
                    }
                }
                progressHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                if completionPredicate.successPredicate == .updating {
                    completion(.success(credential))
                } else {
                    progressHandler(.updating(status: credential.statusPayload))
                }
            case .updated:
                if completionPredicate.successPredicate == .updated {
                    completion(.success(credential))
                }
            case .permanentError:
                completion(.failure(AddCredentialTask.Error.permanentFailure))
            case .temporaryError:
                completion(.failure(AddCredentialTask.Error.temporaryFailure))
            case .authenticationError:
                completion(.failure(AddCredentialTask.Error.authenticationFailed))
            case .disabled:
                fatalError("Credential shouldn't be disabled during creation.")
            case .sessionExpired:
                fatalError("Credential's session shouldn't expire during creation.")
            case .unknown:
                assertionFailure("Unknown credential status!")
            }
        } catch {
            completion(.failure(AddCredentialTask.Error(error: error)))
        }
    }
}
