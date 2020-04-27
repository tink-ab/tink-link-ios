import Foundation

class CredentialsListStatusPollingTask {
    private var service: CredentialsService
    var callRetryCancellable: RetryCancellable?
    private var retryInterval: TimeInterval = 1
    private(set) var credentialsToUpdate: [Credentials]
    private(set) var updatedCredentials: [Credentials] = []
    private var updateHandler: (Result<Credentials, Error>) -> Void
    private var completion: (Result<[Credentials], Error>) -> Void
    private let backoffStrategy: PollingBackoffStrategy
    private var hasPaused = false

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

    init(credentialsService: CredentialsService, credentials: [Credentials], backoffStrategy: PollingBackoffStrategy = .linear, updateHandler: @escaping (Result<Credentials, Error>) -> Void, completion: @escaping (Result<[Credentials], Error>) -> Void) {
        self.service = credentialsService
        self.credentialsToUpdate = credentials
        self.backoffStrategy = backoffStrategy
        self.updateHandler = updateHandler
        self.completion = completion
    }

    func pausePolling() {
        retryInterval = 1
        hasPaused = true
    }

    func continuePolling() {
        hasPaused = false
        pollStatus()
    }

    func pollStatus() {
        // Check the ablility for update the credential, if not, call update handler immediately.
        // Remove the credentials that cannot be updated from the updating list.
        credentialsToUpdate = credentialsToUpdate.filter {
            let updatable = $0.isManuallyUpdatable
            if !updatable {
                updateHandler(.success($0))
            }
            return updatable
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            self.callRetryCancellable = self.service.credentialsList { [weak self] result in
                guard let self = self else { return }
                do {
                    let credentials = try result.get()
                    self.credentialsToUpdate = self.checkCredentialsToUpdate(credentials)

                    if self.credentialsToUpdate.isEmpty {
                        self.completion(.success(self.updatedCredentials))
                    } else {
                        guard !self.hasPaused else { return }
                        self.retry()
                    }
                } catch {
                    self.completion(.failure(error))
                }
            }
        }
    }

    private func checkCredentialsToUpdate(_ fetchedCredentials: [Credentials]) -> [Credentials] {
        // Remove the credentials that have been updated
        return credentialsToUpdate.filter { credential -> Bool in
            if let updatedCredential = fetchedCredentials.first(where: { $0.id == credential.id }) {
                if credential.statusUpdated != updatedCredential.statusUpdated || credential.status != updatedCredential.status {
                    switch updatedCredential.status {
                    // When status is updated, or changed to error, move the credentials to updated credentials list
                    case .updated, .permanentError, .temporaryError, .authenticationError, .unknown, .disabled, .sessionExpired:
                        updateHandler(.success(updatedCredential))
                        updatedCredentials.append(updatedCredential)
                        return false
                    // Status has changed, but not finished updating.
                    default:
                        updateHandler(.success(updatedCredential))
                        return true
                    }
                }
                return true
            } else {
                fatalError("No such credentials with " + credential.id.value)
            }
        }
    }

    private func retry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.callRetryCancellable?.retry()
        }
        retryInterval = backoffStrategy.nextInterval(for: retryInterval)
    }
}
