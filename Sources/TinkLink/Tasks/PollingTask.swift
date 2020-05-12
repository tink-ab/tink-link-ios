import Foundation

class PollingTask<T, S> {
    private let pollingRequest: (T, @escaping ((Result<S, Error>) -> Void)) -> RetryCancellable?
    private let pollingID: T
    private let pollingPredicate: (_ current: S?, _ updated: S) -> Bool
    private let updateHandler: (Result<S, Error>) -> Void
    private let applicationObserver = ApplicationObserver()
    private let retryInterval: TimeInterval = 1

    private var pollingResponseStatus: S?
    private var callRetryCancellable: RetryCancellable?

    private var isPaused = true
    private var isActive = true

    init(pollingID: T, initialStatus: S?, pollingRequest: @escaping (T, @escaping ((Result<S, Error>) -> Void)) -> RetryCancellable?, pollingPredicate: @escaping (_ current: S?, _ updated: S) -> Bool, updateHandler: @escaping (Result<S, Error>) -> Void) {
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
                let pollingResponse = try result.get()

                defer {
                    self.retry()
                }

                guard self.pollingPredicate(self.pollingResponseStatus, pollingResponse) else {
                    return
                }

                self.pollingResponseStatus = pollingResponse
                self.updateHandler(.success(pollingResponse))
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
