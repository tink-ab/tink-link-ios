import Foundation

/// A task that manages progress of adding a credential.
///
/// Use `CredentialsContext` to create a task.
public final class AddCredentialsTask: Identifiable, Cancellable {
    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>
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
        /// The task was cancelled.
        case cancelled

        init?(addCredentialsError error: Swift.Error) {
            switch error {
            case ServiceError.alreadyExists(let payload):
                self = .credentialsAlreadyExists(payload)
            default:
                return nil
            }
        }
    }

    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var thirdPartyAuthenticationTask: ThirdPartyAppAuthenticationTask?

    /// The credentials that are being added.
    public private(set) var credentials: Credentials?

    // MARK: - Evaluating Completion

    /// Cases to evaluate when credentials status changes.
    ///
    /// Use with `CredentialsContext.addCredentials(for:form:completionPredicate:progressHandler:completion:)` to set when add credentials task should call completion handler if successful.
    public struct CompletionPredicate {
        /// Determines when the add credentials task is considered done.
        public enum SuccessPredicate {
            /// A predicate that indicates the credentials' status is `updating`.
            case updating
            /// A predicate that indicates the credentials' status is `updated`.
            case updated
        }

        /// Determines when the add credentials task is considered done.
        public let successPredicate: SuccessPredicate

        /// Determines if the add credentials task should fail if a third party app could not be opened for authentication.
        public let shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool

        /// Determines when the add credentials task is considered done or should fail.
        /// - Parameters:
        ///   - successPredicate: Predicate determining when the add credentials task should succeed.
        ///   - shouldFailOnThirdPartyAppAuthenticationDownloadRequired: A Boolean value determining if the task should fail when a third party app could not be opened.
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
    private var isCancelled = false

    init(credentialsService: CredentialsService, completionPredicate: CompletionPredicate, appUri: URL, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credentials, Swift.Error>) -> Void) {
        self.credentialsService = credentialsService
        self.completionPredicate = completionPredicate
        self.appUri = appUri
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving(_ credentials: Credentials) {
        self.credentials = credentials
        if isCancelled { return }

        handleUpdate(for: .success(credentials))
        credentialsStatusPollingTask = CredentialsStatusPollingTask(
            id: credentials.id,
            initialValue: credentials,
            request: credentialsService.credentials,
            predicate: { (old, new) -> Bool in
                old.statusUpdated != new.statusUpdated || old.status != new.status
            }
        ) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        credentialsStatusPollingTask?.startPolling()
    }

    // MARK: - Controlling the Task

    /// Cancel the task.
    public func cancel() {
        isCancelled = true
        credentialsStatusPollingTask?.stopPolling()
        if let canceller = callCanceller {
            canceller.cancel()
            callCanceller = nil
        } else {
            complete(with: .failure(Error.cancelled))
        }
    }

    private func complete(with result: Result<Credentials, Swift.Error>) {
        credentialsStatusPollingTask?.stopPolling()
        completion(result)
    }

    private func handleUpdate(for result: Result<Credentials, Swift.Error>) {
        if isCancelled { return }
        do {
            let credentials = try result.get()
            switch credentials.status {
            case .created:
                progressHandler(.created)
            case .authenticating:
                progressHandler(.authenticating)
            case .awaitingSupplementalInformation:
                credentialsStatusPollingTask?.stopPolling()
                let supplementInformationTask = SupplementInformationTask(credentialsService: credentialsService, credentials: credentials) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialsStatusPollingTask?.startPolling()
                    } catch {
                        self.complete(with: .failure(error))
                    }
                }
                progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                credentialsStatusPollingTask?.stopPolling()
                guard let thirdPartyAppAuthentication = credentials.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
                }

                let task = ThirdPartyAppAuthenticationTask(credentials: credentials, thirdPartyAppAuthentication: thirdPartyAppAuthentication, appUri: appUri, credentialsService: credentialsService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: completionPredicate.shouldFailOnThirdPartyAppAuthenticationDownloadRequired) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialsStatusPollingTask?.startPolling()
                    } catch {
                        self.complete(with: .failure(error))
                    }
                    self.thirdPartyAuthenticationTask = nil
                }
                thirdPartyAuthenticationTask = task
                progressHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                if completionPredicate.successPredicate == .updating {
                    complete(with: .success(credentials))
                } else {
                    progressHandler(.updating(status: credentials.statusPayload))
                }
            case .updated:
                if completionPredicate.successPredicate == .updated {
                    complete(with: .success(credentials))
                }
            case .permanentError:
                complete(with: .failure(AddCredentialsTask.Error.permanentFailure(credentials.statusPayload)))
            case .temporaryError:
                complete(with: .failure(AddCredentialsTask.Error.temporaryFailure(credentials.statusPayload)))
            case .authenticationError:
                var payload: String
                // Noticed that the frontend could get an unauthenticated error with an empty payload while trying to add the same third-party authentication credentials twice.
                // Happens if the frontend makes the update credentials request before the backend stops waiting for the previously added credentials to finish authenticating or time-out.
                if credentials.kind == .mobileBankID || credentials.kind == .thirdPartyAuthentication {
                    payload = credentials.statusPayload.isEmpty ? "Please try again later" : credentials.statusPayload
                } else {
                    payload = credentials.statusPayload
                }
                complete(with: .failure(AddCredentialsTask.Error.authenticationFailed(payload)))
            case .disabled:
                fatalError("credentials shouldn't be disabled during creation.")
            case .sessionExpired:
                fatalError("Credential's session shouldn't expire during creation.")
            case .unknown:
                assertionFailure("Unknown credentials status!")
            @unknown default:
                assertionFailure("Unknown credentials status!")
            }
        } catch ServiceError.cancelled {
            complete(with: .failure(Error.cancelled))
        } catch {
            complete(with: .failure(error))
        }
    }
}
