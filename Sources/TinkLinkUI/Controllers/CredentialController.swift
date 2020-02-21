import TinkLink
import Foundation

final class CredentialController {
    let tinkLink: TinkLink

    var user: User?

    private(set) var credentialContext: CredentialContext?

    init(tinkLink: TinkLink) {
        self.tinkLink = tinkLink
    }

    func addCredential(_ provider: Provider, form: Form, progressHandler: @escaping (AddCredentialTask.Status) -> Void, completion: @escaping (_ result: Result<Credential, Error>) -> Void) -> AddCredentialTask? {
        guard let user = user else { return nil }
        if credentialContext == nil {
            credentialContext = CredentialContext(user: user)
        }
        return credentialContext?.addCredential(
            for: provider,
            form: form,
            progressHandler: progressHandler,
            completion: completion
        )
    }
}
