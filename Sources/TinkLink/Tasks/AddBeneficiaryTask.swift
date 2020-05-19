import Foundation

public final class AddBeneficiaryTask: Cancellable {
    public enum Authentication {
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
    }

    private let credentialsService: CredentialsService
    private let appUri: URL
    private let authenticationHandler: (Authentication) -> Void
    private let completionHandler: (Result<Beneficiary, Swift.Error>) -> Void

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

    public func cancel() {
        isCancelled = true
    }
}
