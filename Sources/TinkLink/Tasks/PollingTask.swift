import Foundation

final class PollingTask<ID, Model> {
    private let pollingRequest: (ID, @escaping ((Result<Model, Error>) -> Void)) -> RetryCancellable?
    private let pollingID: ID
    private let pollingPredicate: (_ current: Model?, _ updated: Model) -> Bool
    private let updateHandler: (Result<Model, Error>) -> Void
    private let applicationObserver = ApplicationObserver()
    private let retryInterval: TimeInterval = 1

    private var pollingResponseStatus: Model?
    private var callRetryCancellable: RetryCancellable?

    private var isPaused = true
    private var isActive = true

    init(pollingID: ID, initialStatus: Model?, pollingRequest: @escaping (ID, @escaping ((Result<Model, Error>) -> Void)) -> RetryCancellable?, pollingPredicate: @escaping (_ current: Model?, _ updated: Model) -> Bool, updateHandler: @escaping (Result<Model, Error>) -> Void) {
        self.pollingID = pollingID
        self.pollingResponseStatus = initialStatus
        self.pollingPredicate = pollingPredicate
        self.pollingRequest = pollingRequest
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
        if isPaused || !isActive {
            return
        }

        callRetryCancellable = pollingRequest(pollingID) { [weak self] result in
            guard let self = self else { return }
            self.callRetryCancellable = nil
            do {
                let updatedResponseState = try result.get()

                defer {
                    self.retry()
                }

                guard self.pollingPredicate(self.pollingResponseStatus, updatedResponseState) else {
                    return
                }

                self.pollingResponseStatus = updatedResponseState
                self.updateHandler(.success(updatedResponseState))
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
