import TinkLink
import Foundation

final class CredentialsController {
    let tink: Tink
    var user: User?
    private(set) var credentialsContext: CredentialsContext?

    init(tink: Tink) {
        self.tink = tink
        self.credentialsContext = CredentialsContext(tink: tink)
    }

    func addCredentials(_ provider: Provider, form: Form, scopes: [Scope], progressHandler: @escaping (AddCredentialsTask.Status) -> Void, completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> AddCredentialsTask? {
        return credentialsContext?.add(
            for: provider,
            form: form,
            scopes: scopes,
            completionPredicate: AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false),
            progressHandler: progressHandler,
            completion: completion
        )
    }
}
