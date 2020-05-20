import Foundation

public final class InitiateTransferTask {

    typealias TransferStatusPollingTask = PollingTask<Transfer.ID, SignableOperation>
    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>

    public enum Status {
        case created(Transfer.ID)
        case authenticating
        case executing(status: String)
    }

    public enum AuthenticationTask {
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
    }

    public enum Error: Swift.Error {
        /// The authentication failed. The payload from the backend can be found in the associated value.
        case authenticationFailed(String?)
        case disabledCredentials(String?)
        case sessionExpired(String?)
        case cancelled(String?)
        case failed(String?)
    }

    public struct Receipt {
        public let id: Transfer.ID
        public let message: String?
    }

    private(set) var signableOperation: SignableOperation?

    var canceller: Cancellable?

    private let transferService: TransferService
    private let credentialsService: CredentialsService
    private let appUri: URL
    private let progressHandler: (Status) -> Void
    private let authenticationHandler: (AuthenticationTask) -> Void
    private let completionHandler: (Result<Receipt, Swift.Error>) -> Void

    private var transferStatusPollingTask: TransferStatusPollingTask?
    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var thirdPartyAuthenticationTask: ThirdPartyAppAuthenticationTask?
    private var isCancelled = false

    init(transferService: TransferService, credentialsService: CredentialsService, appUri: URL, progressHandler: @escaping (Status) -> Void, authenticationHandler: @escaping (AuthenticationTask) -> Void, completionHandler: @escaping (Result<Receipt, Swift.Error>) -> Void) {
        self.transferService = transferService
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.progressHandler = progressHandler
        self.authenticationHandler = authenticationHandler
        self.completionHandler = completionHandler
    }

    func startObserving(_ signableOperation: SignableOperation) {
        guard let transferID = signableOperation.transferID else {
            complete(with: .failure(Error.failed("Failed to get transfer ID.")))
            return
        }

        self.signableOperation = signableOperation
        if isCancelled { return }

        handleUpdate(for: .success(signableOperation))
        transferStatusPollingTask = TransferStatusPollingTask(
            id: transferID,
            initialValue: signableOperation,
            request: transferService.transferStatus,
            predicate: { (old, new) -> Bool in
                return old.updated != new.updated || old.status != new.status
        }) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        transferStatusPollingTask?.startPolling()
    }

    private func handleUpdate(for result: Result<SignableOperation, Swift.Error>) {
        if isCancelled { return }
        do {
            let signableOperation = try result.get()
            switch signableOperation.status {
            case .created:
                guard let transferID = signableOperation.transferID else {
                    throw Error.failed("Failed to get transfer ID.")
                }
                progressHandler(.created(transferID))
            case .awaitingCredentials, .awaitingThirdPartyAppAuthentication:
                transferStatusPollingTask?.stopPolling()
                if credentialsStatusPollingTask == nil {
                    guard let credentialsID = signableOperation.credentialsID else {
                        throw Error.failed("Failed to get credentials ID.")
                        return
                    }
                    credentialsStatusPollingTask = CredentialsStatusPollingTask(
                        id: credentialsID,
                        initialValue: nil,
                        request: credentialsService.credentials,
                        predicate: {  (old, new) -> Bool in
                            return old.statusUpdated != new.statusUpdated || old.status != new.status
                    }) { [weak self] result in
                        self?.handleUpdate(for: result)
                    }
                }
                credentialsStatusPollingTask?.startPolling()
            case .executing:
                progressHandler(.executing(status: signableOperation.statusMessage ?? ""))
            case .executed:
                complete(with: result)
            case .cancelled:
                throw Error.cancelled(signableOperation.statusMessage)
            case .failed:
                throw Error.failed(signableOperation.statusMessage)
            case .unknown:
                // Error handling?
                break
            }
        } catch {
            complete(with: .failure(error))
        }
    }

    private func handleUpdate(for result: Result<Credentials, Swift.Error>) {
        if isCancelled { return }
        do {
            let credentials = try result.get()
            switch credentials.status {
            case .created: break
            case .authenticating:
                progressHandler(.authenticating)
            case .awaitingSupplementalInformation:
                self.credentialsStatusPollingTask?.stopPolling()
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
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                self.credentialsStatusPollingTask?.stopPolling()
                guard let thirdPartyAppAuthentication = credentials.thirdPartyAppAuthentication else {
                    throw Error.authenticationFailed("Missing third party app authentication information.")
                }

                let task = ThirdPartyAppAuthenticationTask(credentials: credentials, thirdPartyAppAuthentication: thirdPartyAppAuthentication, appUri: appUri, credentialsService: credentialsService, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false) { [weak self] result in
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
                authenticationHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating, .updated:
                // Stops polling when the credentials status is updating
                credentialsStatusPollingTask?.stopPolling()
                transferStatusPollingTask?.startPolling()
            case .permanentError:
                throw Error.failed(credentials.statusPayload)
            case .temporaryError:
                throw Error.failed(credentials.statusPayload)
            case .authenticationError:
                var payload: String
                // Noticed that the frontend could get an unauthenticated error with an empty payload while trying to add the same third-party authentication credentials twice.
                // Happens if the frontend makes the update credentials request before the backend stops waiting for the previously added credentials to finish authenticating or time-out.
                if credentials.kind == .mobileBankID || credentials.kind == .thirdPartyAuthentication {
                    payload = credentials.statusPayload.isEmpty ? "Please try again later" : credentials.statusPayload
                } else {
                    payload = credentials.statusPayload
                }
                throw Error.authenticationFailed(payload)
            case .disabled:
                throw Error.disabledCredentials(credentials.statusPayload)
            case .sessionExpired:
                throw Error.sessionExpired(credentials.statusPayload)
            case .unknown:
                assertionFailure("Unknown credentials status!")
            }
        } catch {
            complete(with: .failure(error))
        }
    }

    private func complete(with result: Result<SignableOperation, Swift.Error>) {
        transferStatusPollingTask?.stopPolling()
        credentialsStatusPollingTask?.stopPolling()
        do {
            let signableOperation = try result.get()
            guard let transferID = signableOperation.transferID else {
                completionHandler(.failure(Error.failed("Failed to get transfer ID.")))
                return
            }

            let response = Receipt(id: transferID, message: signableOperation.statusMessage)
            completionHandler(.success(response))
        } catch {
            completionHandler(.failure(error))
        }
    }

    public func cancel() {
        isCancelled = true
        transferStatusPollingTask?.stopPolling()
        credentialsStatusPollingTask?.stopPolling()
        canceller?.cancel()
    }
}
