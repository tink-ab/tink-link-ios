import TinkLink
import Foundation

final class CredentialsController {
    let tink: Tink
    private(set) lazy var credentialsContext = CredentialsContext(tink: tink)

    init(tink: Tink) {
        self.tink = tink
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) {
        tink._beginUITask()
        defer { tink._endUITask() }
        credentialsContext.fetchCredentials(with: id, completion: completion)
    }

    func addCredentials(_ provider: Provider, form: Form, refreshableItems: RefreshableItems = .all, progressHandler: @escaping (AddCredentialsTask.Status) -> Void, completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> AddCredentialsTask? {
        tink._beginUITask()
        return credentialsContext.add(
            for: provider,
            form: form,
            refreshableItems: refreshableItems,
            completionPredicate: AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false),
            progressHandler: progressHandler,
            completion: { [weak tink] result in
                tink?._endUITask()
                completion(result)
            }
        )
    }

    func update(
        _ credentials: Credentials,
        form: Form? = nil,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: UpdateCredentialsTask.Status) -> Void,
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> UpdateCredentialsTask? {
        tink._beginUITask()
        return credentialsContext.update(
            credentials,
            form: form,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired,
            progressHandler: progressHandler,
            completion: { [weak tink] result in
                tink?._endUITask()
                completion(result)
            }
        )
    }

    func refresh(
        _ credentials: Credentials,
        refreshableItems: RefreshableItems = .all,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: RefreshCredentialsTask.Status) -> Void,
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> RefreshCredentialsTask {
        tink._beginUITask()
        return credentialsContext.refresh(
            credentials,
            refreshableItems: refreshableItems,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired,
            progressHandler: progressHandler,
            completion: { [weak tink] result in
                tink?._endUITask()
                completion(result)
            }
        )
    }

    public func authenticate(
        _ credentials: Credentials,
        shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
        progressHandler: @escaping (_ status: AuthenticateCredentialsTask.Status) -> Void,
        completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void
    ) -> AuthenticateCredentialsTask {
        tink._beginUITask()
        return credentialsContext.authenticate(credentials, progressHandler: progressHandler) { [weak tink] result in
            tink?._endUITask()
            completion(result)
        }
    }
}
