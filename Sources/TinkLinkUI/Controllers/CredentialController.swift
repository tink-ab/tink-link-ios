import TinkLink
import Foundation

final class CredentialController {
    let tink: Tink

    var user: User?

    private(set) var credentialContext: CredentialContext?

    init(tink: Tink) {
        self.tink = tink
    }

    func addCredential(_ provider: Provider, form: Form, progressHandler: @escaping (AddCredentialTask.Status) -> Void, completion: @escaping (_ result: Result<Credential, Error>) -> Void) -> AddCredentialTask? {
        guard let user = user else { return nil }
        if credentialContext == nil {
            credentialContext = CredentialContext(user: user)
        }
        return credentialContext?.addCredential(
            for: provider,
            form: form,
            completionPredicate: AddCredentialTask.CompletionPredicate(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false),
            progressHandler: progressHandler,
            completion: completion
        )
    }
}
