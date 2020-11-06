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
        return add(forProviderWithName: providerName, fields: form.makeFields(), refreshableItems: refreshableItems, completionPredicate: completionPredicate, authenticationHandler: authenticationHandler, progressHandler: progressHandler, completion: completion) as! AddCredentialsTask
    }

    @available(*, unavailable, renamed: "add(for:form:refreshableItems:completionPredicate:authenticationHandler:completion:)")
    public func add(
        for provider: Provider,
        form: Form,
        refreshableItems: RefreshableItems = .all,
        completionPredicate: AddCredentialsTask.CompletionPredicate = .init(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: true),
        progressHandler: @escaping (_ status: AddCredentialsTask.Status) -> Void,
        completion: @escaping (_ result: Result<Credentials, Error>) -> Void
    ) -> AddCredentialsTask {
        fatalError()
    }

    @available(*, unavailable, renamed: "refresh(_:authenticate:refreshableItems:shouldFailOnThirdPartyAppAuthenticationDownloadRequired:authenticationHandler:completion:)")
    public func refresh(
        _ credentials: Credentials,
        authenticate: Bool = false,
        refreshableItems: RefreshableItems = .all,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: RefreshCredentialsTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> RefreshCredentialsTask {
        fatalError()
    }

    @available(*, unavailable, renamed: "update(_:form:shouldFailOnThirdPartyAppAuthenticationDownloadRequired:authenticationHandler:completion:)")
    public func update(
        _ credentials: Credentials,
        form: Form? = nil,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: UpdateCredentialsTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> UpdateCredentialsTask {
        fatalError()
    }

    @available(*, unavailable, renamed: "authenticate(_:shouldFailOnThirdPartyAppAuthenticationDownloadRequired:authenticationHandler:completion:)")
    public func authenticate(
        _ credentials: Credentials,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: AuthenticateCredentialsTask.Status) -> Void = { _ in },
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> AuthenticateCredentialsTask {
        fatalError()
    }
}
