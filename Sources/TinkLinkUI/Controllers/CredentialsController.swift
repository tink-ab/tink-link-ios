import TinkLink
import Foundation

final class CredentialsController {
    let tink: Tink
    private(set) var credentialsContext: CredentialsContext?

    init(tink: Tink) {
        self.tink = tink
        self.credentialsContext = CredentialsContext(tink: tink)
    }

    func addCredentials(_ provider: Provider, form: Form, scopes: [Scope], progressHandler: @escaping (AddCredentialsTask.Status) -> Void, completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> AddCredentialsTask? {
        tink._beginUITask()
        return credentialsContext?.add(
            for: provider,
            form: form,
            refreshableItems: RefreshableItems.makeRefreshableItems(scopes: scopes, provider: provider),
            completionPredicate: AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false),
            progressHandler: progressHandler,
            completion: { [weak tink] result in
                tink?._endUITask()
                completion(result)
            }
        )
    }
}
