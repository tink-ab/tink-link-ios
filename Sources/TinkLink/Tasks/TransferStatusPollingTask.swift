import Foundation

// TODO: Abstruct this and credentials status polling into a common class
final class TransferStatusPollingTask {
    private let service: TransferService
    private let updateHandler: (Result<SignableOperation, Error>) -> Void
    private let applicationObserver = ApplicationObserver()
    private let retryInterval: TimeInterval = 1

    private var signableOperation: SignableOperation
    private var callRetryCancellable: RetryCancellable?

    private var isPaused = true
    private var isActive = true

    init(transferService: TransferService, signableOperation: SignableOperation, updateHandler: @escaping (Result<SignableOperation, Error>) -> Void) {
        self.service = transferService
        self.signableOperation = signableOperation
        self.updateHandler = updateHandler

        applicationObserver.didBecomeActive = { [weak self] in
            guard let self = self, self.isActive == false else { return }
            self.isActive = true
            self.pollStatus()
        }

        applicationObserver.willResignActive = { [weak self] in
            guard let self = self else { return }
            self.isActive = false
            self.callRetryCancellable?.cancel()
            self.callRetryCancellable = nil
        }
    }

    func startPolling() {

        // Only start polling if we're not currently polling.
        guard isPaused else {
            return
        }

        isPaused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            self.pollStatus()
        }
    }

    private func pollStatus() {

        guard let transferID = signableOperation.transferID else {
            // TODO: Call handler with error if cannot find transferID
            return
        }

        if isPaused || !isActive {
            return
        }

        callRetryCancellable = service.transferStatus(transferID: transferID) { [weak self] result in
            guard let self = self else { return }
            self.callRetryCancellable = nil
            do {
                let signableOperation = try result.get()

                defer {
                    self.retry()
                }

                // Check if the operation really updated
                guard signableOperation.updated != self.signableOperation.updated || signableOperation.status != self.signableOperation.status else {
                    return
                }

                self.signableOperation = signableOperation
                self.updateHandler(.success(signableOperation))
            } catch {
                self.updateHandler(.failure(error))
            }
        }
    }

    private func retry() {
        if isPaused { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.pollStatus()
        }
    }

    func stopPolling() {
        callRetryCancellable?.cancel()
        isPaused = true
    }
}
