import TinkLink
import Foundation

final class CredentialController {
    let tink: Tink

    var user: User?

    private(set) var credentialsContext: CredentialsContext?

    init(tink: Tink) {
        self.tink = tink
    }

    func addCredentials(_ provider: Provider, form: Form, progressHandler: @escaping (AddCredentialsTask.Status) -> Void, completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> AddCredentialsTask? {
        guard let user = user else { return nil }
        if credentialsContext == nil {
            credentialsContext = CredentialsContext(user: user)
        }
        return credentialsContext?.addCredentials(
            for: provider,
            form: form,
            completionPredicate: AddCredentialsTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false),
            progressHandler: progressHandler,
            completion: completion
        )
    }
}
