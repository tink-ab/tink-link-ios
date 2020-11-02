import Foundation

extension CredentialsContext {

    // Deprecation: 1.0
    @available(*, deprecated, renamed: "fetchCredentials(withID:completion:)")
    public func fetchCredentials(with id: Credentials.ID, completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return fetchCredentials(withID: id, completion: completion)
    }
    
    // Deprecation: 1.0
    @available(*, deprecated, message: "use add(forProviderWithName:fields:refreshableItems:completionPredicate:authenticationHandler:progressHandler:completion:) instead")
    public func add(
        forProviderWithName providerName: Provider.Name,
        form: Form,
        refreshableItems: RefreshableItems = .all,
        completionPredicate: AddCredentialsTask.CompletionPredicate = .init(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: true),
        authenticationHandler: @escaping (_ task: AuthenticationTask) -> Void,
        progressHandler: @escaping (_ status: AddCredentialsTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<Credentials, Error>) -> Void
    ) -> AddCredentialsTask {
        return add(forProviderWithName: providerName, fields: form.makeFields(), refreshableItems: refreshableItems, completionPredicate: completionPredicate, authenticationHandler: authenticationHandler, progressHandler: progressHandler, completion: completion)
    }
}
