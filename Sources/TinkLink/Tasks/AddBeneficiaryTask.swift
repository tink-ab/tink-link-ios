import Foundation

public final class AddBeneficiaryTask: Cancellable {
    // MARK: Types
    typealias CredentialsStatusPollingTask = PollingTask<Credentials.ID, Credentials>

    public enum Status {
        case started
        case authenticating
        case searching
    }

    public enum AuthenticationTask {
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
    }

    public enum Error: Swift.Error {
        case authenticationFailed(String)
        case disabledCredentials(String)
        case credentialsSessionExpired(String)
        case notFound(String)
    }

    // MARK: Dependencies
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    // MARK: Properties
    private let appUri: URL
    private let ownerAccount: Account
    private let name: String
    private let accountNumberType: String
    private let accountNumber: String
    private let progressHandler: (Status) -> Void
    private let authenticationHandler: (AuthenticationTask) -> Void
    private let completionHandler: (Result<Beneficiary, Swift.Error>) -> Void

    // MARK: Tasks
    private var credentialsStatusPollingTask: CredentialsStatusPollingTask?
    private var supplementInformationTask: SupplementInformationTask?
    private var thirdPartyAppAuthenticationTask: ThirdPartyAppAuthenticationTask?

    var callCanceller: Cancellable?
    private var fetchBeneficiariesCanceller: Cancellable?

    // MARK: State
    private var isCancelled = false
    private var didComplete = false

    // MARK: Initializers
    init(
        transferService: TransferService,
        credentialsService: CredentialsService,
        appUri: URL,
        ownerAccount: Account,
        name: String,
        accountNumberType: String,
        accountNumber: String,
        progressHandler: @escaping (Status) -> Void,
        authenticationHandler: @escaping (AuthenticationTask) -> Void,
        completionHandler: @escaping (Result<Beneficiary, Swift.Error>) -> Void
    ) {
        self.transferService = transferService
        self.credentialsService = credentialsService
        self.appUri = appUri
        self.ownerAccount = ownerAccount
        self.name = name
        self.accountNumberType = accountNumberType
        self.accountNumber = accountNumber
        self.progressHandler = progressHandler
        self.authenticationHandler = authenticationHandler
        self.completionHandler = completionHandler
    }
}

// MARK: - Task Lifecycle

extension AddBeneficiaryTask {
    func start() {
        let request = CreateBeneficiaryRequest(
            accountNumberType: accountNumberType,
            accountNumber: accountNumber,
            name: name,
            ownerAccountID: ownerAccount.id,
            credentialsID: ownerAccount.credentialsID
        )

        callCanceller = transferService.addBeneficiary(request: request) { [weak self, credentialsID = ownerAccount.credentialsID] (result) in
            do {
                try result.get()
                self?.progressHandler(.started)
                self?.startObservingCredentials(id: credentialsID)
            } catch {
                self?.complete(with: .failure(error))
            }
        }
    }

    public func cancel() {
        callCanceller?.cancel()
        fetchBeneficiariesCanceller?.cancel()
        isCancelled = true
    }
}

// MARK: - Credentials Observing

extension AddBeneficiaryTask {
    private func startObservingCredentials(id: Credentials.ID) {
        if isCancelled { return }

        credentialsStatusPollingTask = CredentialsStatusPollingTask(
            id: id,
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

    private func handleUpdate(for result: Result<Credentials, Swift.Error>) {
        if isCancelled { return }
        do {
            let credentials = try result.get()
            try handleCredentials(credentials)
        } catch {
            complete(with: .failure(error))
        }
    }

    private func handleCredentials(_ credentials: Credentials) throws {
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
            throw Error.authenticationFailed(credentials.statusPayload)
        case .temporaryError:
            throw Error.authenticationFailed(credentials.statusPayload)
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
            throw Error.credentialsSessionExpired(credentials.statusPayload)
        case .unknown:
            assertionFailure("Unknown credentials status!")
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
            _ = try result.get()
            progressHandler(.searching)
            fetchBeneficiary(accountID: ownerAccount.id, accountNumberType: accountNumberType, accountNumber: accountNumber) { [weak self] (beneficiaryResult) in
                do {
                    let addedBeneficiary = try beneficiaryResult.get()
                    self?.completionHandler(.success(addedBeneficiary))
                } catch {
                    self?.completionHandler(.failure(error))
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
    }

    private func fetchBeneficiary(
        accountID: Account.ID,
        accountNumberType: String,
        accountNumber: String,
        completion: @escaping (Result<Beneficiary, Swift.Error>) -> Void
    ) {
        fetchBeneficiariesCanceller = transferService.beneficiaries { result in
            do {
                let beneficiaries = try result.get()
                let beneficiary = beneficiaries.first(where: { beneficiary in
                    beneficiary.ownerAccountID == accountID && beneficiary.accountNumberType == accountNumberType && beneficiary.accountNumber == accountNumber
                })
                guard let matchingBeneficiary = beneficiary else {
                    throw Error.notFound("Could not find added beneficiary.")
                }
                completion(.success(matchingBeneficiary))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
