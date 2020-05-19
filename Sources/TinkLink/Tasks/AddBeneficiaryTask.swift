import Foundation

public final class AddBeneficiaryTask: Cancellable {
    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>

    public enum Authentication {
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
    }

    public enum Error: Swift.Error {
        case authenticationFailed(String)
        case temporaryFailure(String)
        case permanentFailure(String)
        case disabledCredentials(String)
        case sessionExpired(String)
    }

    private let credentialsService: CredentialsService
    private let appUri: URL
    private let authenticationHandler: (Authentication) -> Void
    private let completionHandler: (Result<Beneficiary, Swift.Error>) -> Void

    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var isCancelled = false

    init(
        credentialsService: CredentialsService,
        appUri: URL,
        authenticationHandler: @escaping (Authentication) -> Void,
        completionHandler: @escaping (Result<Beneficiary, Swift.Error>) -> Void
    ) {
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.authenticationHandler = authenticationHandler
        self.completionHandler = completionHandler
    }

    func startObservingCredentials(for account: Account) {
        if isCancelled { return }

        credentialsStatusPollingTask = CredentialsStatusPollingTask(
            id: account.credentialsID,
            initialValue: nil,
            request: credentialsService.credentials,
            predicate: { (old, new) in
                old.statusUpdated != new.statusUpdated || old.status != new.status
            },
            updateHandler: { [weak self] result in
            }
        )

        credentialsStatusPollingTask?.startPolling()
    }

    public func cancel() {
        isCancelled = true
    }
}
