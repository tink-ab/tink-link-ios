import Foundation

public final class AddBeneficiaryTask: Cancellable {
    // MARK: Types
    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>

    public enum Status {
        case created
        case authenticating
        case searching
    }

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
        case addingFailed(String)
    }

    // MARK: Dependencies
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    // MARK: Properties
    private let appUri: URL
    private let sourceAccount: Account
    private let accountNumber: String
    private let progressHandler: (Status) -> Void
    private let authenticationHandler: (Authentication) -> Void
    private let completionHandler: (Result<Beneficiary, Swift.Error>) -> Void

    // MARK: Tasks
    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var supplementInformationTask: SupplementInformationTask?
    private var thirdPartyAppAuthenticationTask: ThirdPartyAppAuthenticationTask?

    var callCanceller: Cancellable?

    // MARK: State
    private var isCancelled = false
    private var didComplete = false

    // MARK: Initializers
    init(
        transferService: TransferService,
        credentialsService: CredentialsService,
        appUri: URL,
        sourceAccount: Account,
        accountNumber: String,
        progressHandler: @escaping (Status) -> Void,
        authenticationHandler: @escaping (Authentication) -> Void,
        completionHandler: @escaping (Result<Beneficiary, Swift.Error>) -> Void
    ) {
        self.transferService = transferService
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.sourceAccount = sourceAccount
        self.accountNumber = accountNumber
        self.progressHandler = progressHandler
        self.authenticationHandler = authenticationHandler
        self.completionHandler = completionHandler
    }
}

// MARK: - Task Lifecycle

extension AddBeneficiaryTask {
    func startObservingCredentials(for account: Account) {
        if isCancelled { return }

        progressHandler(.created)

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
        callCanceller?.cancel()
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
                progressHandler(.authenticating)
            case .awaitingSupplementalInformation:
                self.credentialsStatusPollingTask?.stopPolling()
                let task = makeSupplementInformationTask(for: credentials) { [weak self] result in
                    do {
                        try result.get()
                        self?.credentialsStatusPollingTask?.startPolling()
                    } catch {
                        self?.complete(with: .failure(error))
                    }
                    self?.supplementInformationTask = nil
                }
                supplementInformationTask = task
                authenticationHandler(.awaitingSupplementalInformation(task))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                self.credentialsStatusPollingTask?.stopPolling()
                let task = try makeThirdPartyAppAuthenticationTask(for: credentials) { [weak self] result in
                    do {
                        try result.get()
                        self?.credentialsStatusPollingTask?.startPolling()
                    } catch {
                        self?.complete(with: .failure(error))
                    }
                    self?.thirdPartyAppAuthenticationTask = nil
                }
                thirdPartyAppAuthenticationTask = task
                authenticationHandler(.awaitingThirdPartyAppAuthentication(task))
            case .updating:
                complete(with: .success(credentials))
            case .updated:
                complete(with: .success(credentials))
            case .permanentError:
                throw Error.permanentFailure(credentials.statusPayload)
            case .temporaryError:
                throw Error.temporaryFailure(credentials.statusPayload)
            case .authenticationError:
                var payload: String
                // Noticed that the frontend could get an unauthenticated error with an empty payload while trying to add the same third-party authentication credentials twice.
                // Happens if the frontend makes the update credentials request before the backend stops waiting for the previously added credentials to finish authenticating or time-out.
                if credentials.kind == .mobileBankID || credentials.kind == .thirdPartyAuthentication {
                    payload = credentials.statusPayload.isEmpty ? "Please try again later" : credentials.statusPayload
                } else {
                    payload = credentials.statusPayload
                }
                throw Error.authenticationFailed(payload)
            case .disabled:
                throw Error.disabledCredentials(credentials.statusPayload)
            case .sessionExpired:
                throw Error.sessionExpired(credentials.statusPayload)
            case .unknown:
                assertionFailure("Unknown credentials status!")
            }
        } catch {
            complete(with: .failure(error))
        }
    }
}

// MARK: - Awaiting Authentication Helpers

extension AddBeneficiaryTask {
    private func makeSupplementInformationTask(for credentials: Credentials, completion: @escaping (Result<Void, Swift.Error>) -> Void) -> SupplementInformationTask {
        return SupplementInformationTask(
            credentialsService: credentialsService,
            credentials: credentials,
            completionHandler: completion
        )
    }

    private func makeThirdPartyAppAuthenticationTask(for credentials: Credentials, completion: @escaping (Result<Void, Swift.Error>) -> Void) throws -> ThirdPartyAppAuthenticationTask {
        guard let thirdPartyAppAuthentication = credentials.thirdPartyAppAuthentication else {
            throw Error.authenticationFailed("Missing third party app authentication deeplink URL.")
        }

        return ThirdPartyAppAuthenticationTask(
            credentials: credentials,
            thirdPartyAppAuthentication: thirdPartyAppAuthentication,
            appUri: appUri,
            credentialsService: credentialsService,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            completionHandler: completion
        )
    }
}

// MARK: - Task Completion

extension AddBeneficiaryTask {
    private func complete(with result: Result<Credentials, Swift.Error>) {
        if didComplete { return }
        defer { didComplete = true }

        credentialsStatusPollingTask?.stopPolling()
        do {
            let credentials = try result.get()
            progressHandler(.searching)
            transferService.beneficiaries { [weak self, accountID = sourceAccount.id, accountNumber] (beneficiariesResult) in
                do {
                    let beneficiaries = try beneficiariesResult.get()
                    let beneficiary = beneficiaries.first(where: { beneficiary in
                        // TODO: Check accountNumberType also.
                        beneficiary.ownerAccountID == accountID && beneficiary.accountNumber == accountNumber
                    })
                    guard let addedBeneficiary = beneficiary else {
                        throw Error.addingFailed("Could not find added beneficiary.")
                    }
                    self?.completionHandler(.success(addedBeneficiary))
                } catch {
                    self?.completionHandler(.failure(error))
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
}
