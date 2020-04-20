import Foundation

class CredentialsStatusPollingTask {
    private var service: CredentialsService
    private var callRetryCancellable: RetryCancellable?
    private var retryInterval: TimeInterval = 1
    private(set) var credentials: Credentials
    private var updateHandler: (Result<Credentials, Error>) -> Void

    private let applicationObserver = ApplicationObserver()

    private var isPaused = true
    private var isActive = true
    private var lastStatusUpdated: Date?

    init(credentialsService: CredentialsService, credentials: Credentials, updateHandler: @escaping (Result<Credentials, Error>) -> Void) {
        self.service = credentialsService
        self.credentials = credentials
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
        retryInterval = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            self.pollStatus()
        }
    }

    private func pollStatus() {

        if isPaused || !isActive {
            return
        }

        self.callRetryCancellable = self.service.credentials(id: self.credentials.id) { [weak self] result in
            guard let self = self else { return }
            self.callRetryCancellable = nil
            do {
                let credentials = try result.get()

                defer {
                    self.retry()
                }

                // Only call updateHandler if status has actually changed.
                guard credentials.statusUpdated != self.lastStatusUpdated else {
                    return
                }

                self.lastStatusUpdated = credentials.statusUpdated
                self.updateHandler(.success(credentials))
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
