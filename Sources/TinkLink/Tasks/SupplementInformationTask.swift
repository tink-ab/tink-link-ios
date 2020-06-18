/// A task that handles submitting supplemental information.
///
/// This task is provided when e.g. an `AddCredentialsTask`'s status changes to `awaitingSupplementalInformation`.
///
/// When a task's status is `awaitingSupplementalInformation` the user needs to provide additional information to finish the task.
///
/// Create a form for the provided task.
///
/// ```swift
/// let form = Form(supplementInformationTask: supplementInformationTask)
/// form.fields[0].text = <#String#>
/// form.fields[1].text = <#String#>
/// ```
///
/// Submit update supplement information after validating like this:
///
/// ```swift
/// do {
///   try form.validateFields()
///    supplementInformationTask.submit(form)
/// } catch {
///    <#Handle error#>
/// }
/// ```
///
/// After submitting the form, the parent task will continue.
///
/// - Note: If the user dismiss supplementing information, by e.g. closing the form, you need to call `cancel()` to stop adding the credentials.
public final class SupplementInformationTask: Identifiable {
    private let credentialsService: CredentialsService
    private var callRetryCancellable: RetryCancellable?

    // MARK: Getting the Credentials

    /// The credentials that's awaiting supplemental information.
    public let credentials: Credentials

    private let completionHandler: (Result<Void, Error>) -> Void

    init(credentialsService: CredentialsService, credentials: Credentials, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.credentialsService = credentialsService
        self.credentials = credentials
        self.completionHandler = completionHandler
    }

    // MARK: - Submitting a Form

    /// Submits the provided form fields.
    ///
    /// - Parameter form: This is a form with fields from the credentials that had status `awaitingSupplementalInformation`.
    public func submit(_ form: Form) {
        callRetryCancellable = credentialsService.supplementInformation(id: credentials.id, fields: form.makeFields(), completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }

    // MARK: - Controlling the Task

    /// Tells the credentials to stop waiting for supplemental information.
    ///
    /// Call this method if the user dismiss the form to supplement information.
    public func cancel() {
        callRetryCancellable = credentialsService.cancelSupplementInformation(id: credentials.id, completion: { [weak self] result in
            switch result {
            case .success:
                self?.completionHandler(.failure(ServiceError.cancelled))
            case .failure(let error):
                self?.completionHandler(.failure(error))
            }
            self?.callRetryCancellable = nil
        })
    }
}
