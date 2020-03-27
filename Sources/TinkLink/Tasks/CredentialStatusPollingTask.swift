import Foundation

class CredentialStatusPollingTask {
    private var service: CredentialsService
    var callRetryCancellable: RetryCancellable?
    private var retryInterval: TimeInterval = 1
    private(set) var credentials: Credentials
    private var updateHandler: (Result<Credentials, Error>) -> Void
    private let backoffStrategy: PollingBackoffStrategy

    private var isCancelled = false

    enum PollingBackoffStrategy {
        case none
        case linear
        case exponential

        func nextInterval(for retryinterval: TimeInterval) -> TimeInterval {
            switch self {
            case .none:
                return retryinterval
            case .linear:
                return retryinterval + 1
            case .exponential:
                return retryinterval * 2
            }
        }
    }

    init(credentialsService: CredentialsService, credentials: Credentials, backoffStrategy: PollingBackoffStrategy = .linear, updateHandler: @escaping (Result<Credentials, Error>) -> Void) {
        self.service = credentialsService
        self.credentials = credentials
        self.backoffStrategy = backoffStrategy
        self.updateHandler = updateHandler
    }

    func pollStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            self.callRetryCancellable = self.service.credentials(id: self.credentials.id) { [weak self] result in
                guard let self = self else { return }
                do {
                    let credentials = try result.get()
                    switch credentials.status {
                    case .awaitingSupplementalInformation, .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication:
                        if self.credentials.statusUpdated != credentials.statusUpdated {
                            self.callRetryCancellable = nil
                            self.updateHandler(.success(credentials))
                        } else {
                            self.retry()
                        }
                    case .created, .authenticating, .updating:
                        self.updateHandler(.success(credentials))
                        self.retry()
                    case self.credentials.status where self.credentials.kind == .thirdPartyAuthentication || self.credentials.kind == .mobileBankID:
                        if self.credentials.statusUpdated != credentials.statusUpdated {
                            self.updateHandler(.success(credentials))
                            self.callRetryCancellable = nil
                        } else {
                            self.retry()
                        }
                    default:
                        self.updateHandler(.success(credentials))
                        self.callRetryCancellable = nil
                    }
                } catch {
                    self.updateHandler(.failure(error))
                }
            }
        }
    }

    private func retry() {
        if isCancelled { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            if self?.isCancelled == true { return }
            self?.pollStatus()
        }
        retryInterval = backoffStrategy.nextInterval(for: retryInterval)
    }

    func cancel() {
        callRetryCancellable?.cancel()
        isCancelled = true
    }
}
