import Foundation

enum PollingStrategy {
    case constant(TimeInterval)
    case linear(TimeInterval, maxInterval: TimeInterval)

    func nextInterval(after previousInterval: TimeInterval) -> TimeInterval {
        switch self {
        case .constant(let interval):
            return interval
        case .linear(let interval, maxInterval: let maxInterval):
            return min(previousInterval + interval, maxInterval)
        }
    }

    var initialInterval: TimeInterval {
        switch self {
        case .constant(let interval), .linear(let interval, maxInterval: _):
            return interval
        }
    }

    var maxPollingTime: TimeInterval {
        switch self {
        case .constant(_), .linear(_, maxInterval: _):
            return 1800
        }
    }
}

final class PollingTask<ID, Model> {
    var pollingStrategy: PollingStrategy = .linear(1.0, maxInterval: 10)

    private var interval: TimeInterval
    private var maxCount: TimeInterval

    private let request: (ID, @escaping ((Result<Model, Error>) -> Void)) -> RetryCancellable?
    private let id: ID
    private let predicate: (_ old: Model, _ new: Model) -> Bool
    private let updateHandler: (Result<Model, Error>) -> Void
    private let applicationObserver = ApplicationObserver()

    private var responseValue: Model?
    private var callRetryCancellable: RetryCancellable?

    private var isPaused = true
    private var isActive = true

    init(id: ID, initialValue: Model?, request: @escaping (ID, @escaping ((Result<Model, Error>) -> Void)) -> RetryCancellable?, predicate: @escaping (_ old: Model, _ new: Model) -> Bool, updateHandler: @escaping (Result<Model, Error>) -> Void) {
        self.id = id
        self.responseValue = initialValue
        self.predicate = predicate
        self.request = request
        self.updateHandler = updateHandler
        self.interval = pollingStrategy.initialInterval
        self.maxCount = pollingStrategy.maxPollingTime

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
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.pollStatus()
        }
    }

    private func pollStatus() {
        if isPaused || !isActive || maxCount < 1 {
            return
        }

        callRetryCancellable = request(id) { [weak self] result in
            guard let self = self else { return }
            self.callRetryCancellable = nil
            do {
                let newValue = try result.get()

                defer {
                    self.retry()
                }

                if let oldValue = self.responseValue, !self.predicate(oldValue, newValue) {
                    return
                }

                // Something has changed: Reset polling interval.
                self.interval = self.pollingStrategy.initialInterval
                self.responseValue = newValue
                self.updateHandler(.success(newValue))
            } catch {
                self.updateHandler(.failure(error))
            }
        }
    }

    private func retry() {
        if isPaused { return }

        interval = pollingStrategy.nextInterval(after: interval)
        maxCount -= interval
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
            self?.pollStatus()
        }
    }

    func stopPolling() {
        callRetryCancellable?.cancel()
        isPaused = true
    }
}
