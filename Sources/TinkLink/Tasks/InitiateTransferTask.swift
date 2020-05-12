import Foundation

public final class InitiateTransferTask {

    public enum Status {
        case created
        case authenticating
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
        case executing
    }

    private(set) public var signableOperation: SignableOperation?

    private let transferService: TransferService
    private let progressHandler: (Status) -> Void
    private let completionHandler: (Result<SignableOperation, Error>) -> Void

    private var transferStatusPollingTask: TransferStatusPollingTask?
    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var isCancelled = false
    private var canceller: Cancellable?

    init(transferService: TransferService, progressHandler: @escaping (Status) -> Void, completionHandler: @escaping (Result<SignableOperation, Error>) -> Void) {
        self.transferService = transferService
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }

    func startObserving(_ signableOperation: SignableOperation) {
        self.signableOperation = signableOperation
        if isCancelled { return }

        handleUpdate(for: .success(signableOperation))
        transferStatusPollingTask = TransferStatusPollingTask(transferService: transferService, signableOperation: signableOperation) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        transferStatusPollingTask?.startPolling()
    }

    private func handleUpdate(for result: Result<SignableOperation, Swift.Error>) {

    }

    public func cancel() {
        canceller?.cancel()
    }
}
