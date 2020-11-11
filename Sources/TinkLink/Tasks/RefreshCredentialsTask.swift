import Foundation

/// A task that manages progress of authenticating a credential.
///
/// Use `CredentialsContext` to create a task.
public typealias AuthenticateCredentialsTask = RefreshCredentialsTask

/// A task that manages progress of updating a credential.
///
/// Use `CredentialsContext` to create a task.
public typealias UpdateCredentialsTask = RefreshCredentialsTask

/// A task that manages progress of refreshing a credential.
///
/// Use `CredentialsContext` to create a task.
public final class RefreshCredentialsTask: Identifiable, Cancellable {
    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>

    /// Indicates the state of a credentials being refreshed.
    public enum Status {
        /// The user needs to be authenticated. The payload from the backend can be found in the associated value.
        case authenticating(String?)

        /// User has been successfully authenticated, now downloading data.
        case updating
    }

    /// Error that the `RefreshCredentialsTask` can throw.
    public struct Error: Swift.Error {
        public struct Code: Equatable, RawRepresentable {
            public let rawValue: Int

            public init?(rawValue: Int) {
                guard (Self.authenticationFailed.rawValue...Self.cancelled.rawValue).contains(rawValue) else { return nil }
                self.rawValue = rawValue
            }

            private init(value: Int) {
                self.rawValue = value
            }

            /// The authentication failed. The payload from the backend can be found in the associated value.
            public static let authenticationFailed = Self(value: 1)
            /// A temporary failure occurred. The payload from the backend can be found in the associated value.
            public static let temporaryFailure = Self(value: 2)
            /// A permanent failure occurred. The payload from the backend can be found in the associated value.
            public static let permanentFailure = Self(value: 3)
            /// The credentials are deleted. The payload from the backend can be found in the associated value.
            public static let deleted = Self(value: 4)
            /// The task was cancelled.
            public static let cancelled = Self(value: 5)
        }
        public var code: Code
        public var message: String?

        static func authenticationFailed(_ message: String?) -> Self {
            .init(code: .authenticationFailed, message: message)
        }
        static func temporaryFailure(_ message: String?) -> Self {
            .init(code: .temporaryFailure, message: message)
        }
        static func permanentFailure(_ message: String?) -> Self {
            .init(code: .permanentFailure, message: message)
        }
        static func deleted(_ message: String?) -> Self {
            .init(code: .deleted, message: message)
        }

        static let cancelled = Self(code: .cancelled)
    }

    var retryInterval: TimeInterval = 1.0

    // MARK: - Retrieving Failure Requirements

    /// Determines how the task handles the case when a user doesn't have the required authentication app installed.
    public let shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool

    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?

    // MARK: - Getting the Credentials

    /// The credentials that are being refreshed.
    public private(set) var credentials: Credentials

    private let credentialsService: CredentialsService
    private let appUri: URL
    let progressHandler: (Status) -> Void
    private let authenticationHandler: AuthenticationTaskHandler

    let completion: (Result<Credentials, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credentials: Credentials, credentialsService: CredentialsService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool, appUri: URL, progressHandler: @escaping (Status) -> Void, authenticationHandler: @escaping AuthenticationTaskHandler, completion: @escaping (Result<Credentials, Swift.Error>) -> Void) {
        self.credentials = credentials
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.progressHandler = progressHandler
        self.authenticationHandler = authenticationHandler
        self.shouldFailOnThirdPartyAppAuthenticationDownloadRequired = shouldFailOnThirdPartyAppAuthenticationDownloadRequired
        self.completion = completion
    }

    func startObserving() {
        credentialsStatusPollingTask = CredentialsStatusPollingTask(
            id: credentials.id,
            initialValue: nil, // We always want to catch the first status change
            request: credentialsService.credentials,
            predicate: { (old, new) -> Bool in
                old.statusUpdated != new.statusUpdated || old.status != new.status
            }
        ) { [weak self] result in
            self?.handleUpdate(for: result)
        }
        credentialsStatusPollingTask?.retryInterval = retryInterval
        credentialsStatusPollingTask?.startPolling()
    }

    // MARK: - Controlling the Task

    /// Cancel the task.
    public func cancel() {
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
        do {
            let credentials = try result.get()
            switch credentials.status {
            case .created:
                break
            case .authenticating:
                progressHandler(.authenticating(credentials.statusPayload))
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
                authenticationHandler(.awaitingSupplementalInformation(supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication), .awaitingMobileBankIDAuthentication(let thirdPartyAppAuthentication):

                credentialsStatusPollingTask?.stopPolling()
                let task = ThirdPartyAppAuthenticationTask(credentials: credentials, thirdPartyAppAuthentication: thirdPartyAppAuthentication, appUri: appUri, credentialsService: credentialsService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialsStatusPollingTask?.startPolling()
                    } catch {
                        self.complete(with: .failure(error))
                    }
                }
                authenticationHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                progressHandler(.updating)
            case .updated:
                complete(with: .success(credentials))
            case .sessionExpired:
                break
            case .authenticationError:
                throw Error.authenticationFailed(credentials.statusPayload)
            case .permanentError:
                throw Error.permanentFailure(credentials.statusPayload)
            case .temporaryError:
                throw Error.temporaryFailure(credentials.statusPayload)
            case .deleted:
                throw Error.deleted(credentials.statusPayload)
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
