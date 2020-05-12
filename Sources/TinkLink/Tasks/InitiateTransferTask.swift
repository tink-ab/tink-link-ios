import Foundation

public final class InitiateTransferTask {

    public enum Status {
        case created
        case authenticating
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
        case executing(status: String)
    }

    private(set) public var signableOperation: SignableOperation?

    private let transferService: TransferService
    private let credentialsService: CredentialsService
    private let appUri: URL
    private let progressHandler: (Status) -> Void
    private let completionHandler: (Result<SignableOperation, Error>) -> Void

    private var transferStatusPollingTask: TransferStatusPollingTask?
    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var thirdPartyAuthenticationTask: ThirdPartyAppAuthenticationTask?
    private var isCancelled = false
    private var canceller: Cancellable?

    init(transferService: TransferService, credentialsService: CredentialsService, appUri: URL, progressHandler: @escaping (Status) -> Void, completionHandler: @escaping (Result<SignableOperation, Error>) -> Void) {
        self.transferService = transferService
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }

    func startObserving(_ signableOperation: SignableOperation) {
        guard let credentialsID = signableOperation.credentialsID else {
            // TODO: Error handling
            complete(with: .failure(CocoaError(.coderValueNotFound)))
            return
        }

        self.signableOperation = signableOperation
        if isCancelled { return }

        handleUpdate(for: .success(signableOperation))
        transferStatusPollingTask = TransferStatusPollingTask(transferService: transferService, signableOperation: signableOperation) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        credentialsStatusPollingTask = CredentialsStatusPollingTask(credentialsService: credentialsService, credentialsID: credentialsID, initialStatus: .created) { [weak self] result in
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
                progressHandler(.created)
            case .awaitingCredentials, .awaitingThirdPartyAppAuthentication:
                transferStatusPollingTask?.stopPolling()
            case .executing:
                progressHandler(.executing(status: signableOperation.statusMessage ?? ""))
            case .executed:
                complete(with: result)
            case .cancelled:
                // Error handling
                break
            case .failed:
                // Error handling
                break
            case .unknown:
                // Error handling
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
                progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                self.credentialsStatusPollingTask?.stopPolling()
                guard let thirdPartyAppAuthentication = credentials.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
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
                progressHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating, .updated:
                // Stops polling when the credentials status is updating
                credentialsStatusPollingTask?.stopPolling()
                transferStatusPollingTask?.startPolling()
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
            }
        } catch {
            complete(with: .failure(error))
        }
    }

    private func complete(with result: Result<SignableOperation, Swift.Error>) {
        transferStatusPollingTask?.stopPolling()
        credentialsStatusPollingTask?.stopPolling()
        completionHandler(result)
    }

    public func cancel() {
        canceller?.cancel()
    }
}
