import TinkLinkSDK
import Foundation

extension Notification.Name {
    static let credentialControllerDidUpdateCredentials = Notification.Name("CredentialControllerDidUpdateCredentials")
    static let credentialControllerDidFinishRefreshingCredentials = Notification.Name("credentialControllerDidFinishRefreshingCredentials")
    static let credentialControllerDidAddCredential = Notification.Name("CredentialControllerDidAddCredential")
    static let credentialControllerDidUpdateStatus = Notification.Name("CredentialControllerDidUpdateStatus")
    static let credentialControllerDidSupplementInformation = Notification.Name("CredentialControllerDidSupplementInformation")
    static let credentialControllerDidError = Notification.Name("CredentialControllerDidError")
}

final class CredentialController {
    let tinkLink: TinkLink

    var credentials: [Credential] = [] {
        didSet {
            NotificationCenter.default.post(name: .credentialControllerDidUpdateCredentials, object: nil)
        }
    }
    var user: User?

    var updatedCredentials: [Credential] = []
    private(set) var supplementInformationTask: SupplementInformationTask?

    private(set) var credentialContext: CredentialContext?
    private var addCredentialTask: AddCredentialTask?

    init(tinkLink: TinkLink) {
        self.tinkLink = tinkLink
    }

    func addCredential(_ provider: Provider, form: Form) {
        guard let user = user else { return }
        if credentialContext == nil {
            credentialContext = CredentialContext(user: user)
        }
        addCredentialTask = credentialContext?.addCredential(
            for: provider,
            form: form,
            progressHandler: { [weak self] in self?.createProgressHandler(for: $0) },
            completion: { [weak self] in self?.createCompletionHandler(result: $0) }
        )
    }

    func cancelAddCredential() {
        addCredentialTask?.cancel()
    }

    private func createProgressHandler(for status: AddCredentialTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
            NotificationCenter.default.post(name: .credentialControllerDidSupplementInformation, object: nil)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.openThirdPartyApp()
        case .updating(let status):
            let parameters = ["status": status]
            NotificationCenter.default.post(name: .credentialControllerDidUpdateStatus, object: nil, userInfo: parameters)
        }
    }

    private func createCompletionHandler(result: Result<Credential, Error>) {
        do {
            let credential = try result.get()
            credentials.append(credential)
            NotificationCenter.default.post(name: .credentialControllerDidAddCredential, object: nil)
        } catch {
            let parameters = ["error": error]
            NotificationCenter.default.post(name: .credentialControllerDidError, object: nil, userInfo: parameters)
        }
    }
}
