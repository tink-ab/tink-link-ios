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
    private var supplementInformationTask: SupplementInformationTask?
    private var thirdPartyAppAuthenticationTask: ThirdPartyAppAuthenticationTask?

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
                self?.handleUpdate(for: result)
            }
        )

        credentialsStatusPollingTask?.startPolling()
    }

    public func cancel() {
        isCancelled = true
    }

    private func handleUpdate(for result: Result<Credentials, Swift.Error>) {
        if isCancelled { return }
        do {
            let credentials = try result.get()
            switch credentials.status {
            case .created:
                break
            case .authenticating:
                break
            case .awaitingSupplementalInformation:
                self.credentialsStatusPollingTask?.stopPolling()
                let task = SupplementInformationTask(credentialsService: credentialsService, credentials: credentials) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialsStatusPollingTask?.startPolling()
                    } catch {
                        self.complete(with: .failure(error))
                    }
                }
                supplementInformationTask = task
                authenticationHandler(.awaitingSupplementalInformation(task))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                self.credentialsStatusPollingTask?.stopPolling()
                guard let thirdPartyAppAuthentication = credentials.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third party app authentication deeplink URL!")
                    return
                }

                let task = ThirdPartyAppAuthenticationTask(
                    credentials: credentials,
                    thirdPartyAppAuthentication: thirdPartyAppAuthentication,
                    appUri: appUri,
                    credentialsService: credentialsService,
                    shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
                    completionHandler: { [weak self] result in
                        guard let self = self else { return }
                        do {
                            try result.get()
                            self.credentialsStatusPollingTask?.startPolling()
                        } catch {
                            self.complete(with: .failure(error))
                        }
                        self.thirdPartyAppAuthenticationTask = nil
                    }
                )
                thirdPartyAppAuthenticationTask = task
                authenticationHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                break
            case .updated:
                complete(with: .success(credentials))
            case .permanentError:
                complete(with: .failure(Error.permanentFailure(credentials.statusPayload)))
            case .temporaryError:
                complete(with: .failure(Error.temporaryFailure(credentials.statusPayload)))
            case .authenticationError:
                var payload: String
                // Noticed that the frontend could get an unauthenticated error with an empty payload while trying to add the same third-party authentication credentials twice.
                // Happens if the frontend makes the update credentials request before the backend stops waiting for the previously added credentials to finish authenticating or time-out.
                if credentials.kind == .mobileBankID || credentials.kind == .thirdPartyAuthentication {
                    payload = credentials.statusPayload.isEmpty ? "Please try again later" : credentials.statusPayload
                } else {
                    payload = credentials.statusPayload
                }
                complete(with: .failure(Error.authenticationFailed(payload)))
            case .disabled:
                complete(with: .failure(Error.disabledCredentials(credentials.statusPayload)))
            case .sessionExpired:
                complete(with: .failure(Error.sessionExpired(credentials.statusPayload)))
            case .unknown:
                assertionFailure("Unknown credentials status!")
            }
        } catch {
            complete(with: .failure(error))
        }
    }

    private func complete(with result: Result<Credentials, Swift.Error>) {
        credentialsStatusPollingTask?.stopPolling()
        do {
            let credentials = try result.get()
            // TODO: Fetch beneficiaries endpoint and get added beneficiary.
        } catch {
            completionHandler(.failure(error))
        }
    }
}
