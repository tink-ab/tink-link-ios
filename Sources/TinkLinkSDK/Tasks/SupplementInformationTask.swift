/// A task that handles submitting supplemental information for a credential.
///
/// This task is provided when an `AddCredentialTask`'s status changes to `awaitingSupplementalInformation`.
///
/// When a credential's status is `awaitingSupplementalInformation` the user needs to provide additional information to finish adding the credential.

/// - Note: If the user dismiss supplementing information, by e.g. closing the form, you need to call `cancel()` to stop adding the credential.
public final class SupplementInformationTask: Identifiable {
    private let credentialService: CredentialService
    private var callRetryCancellable: RetryCancellable?

    /// The credential that's awaiting supplemental information.
    public let credential: Credential

    private let completionHandler: (Result<Void, Error>) -> Void

    init(credentialService: CredentialService, credential: Credential, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.credentialService = credentialService
        self.credential = credential
        self.completionHandler = completionHandler
    }

    /// Submits the provided form fields.
    ///
    /// - Parameter form: This is a form with fields from the credential that had status `awaitingSupplementalInformation`.
    public func submit(_ form: Form) {
        callRetryCancellable = credentialService.supplementInformation(credentialID: credential.id, fields: form.makeFields(), completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }

    /// Tells the credential to stop waiting for supplemental information.
    ///
    /// Call this method if the user dismiss the form to supplement information.
    public func cancel() {
        callRetryCancellable = credentialService.cancelSupplementInformation(credentialID: credential.id, completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }
}
