import TinkLink
import Foundation

extension Notification.Name {
    static let credentialsControllerDidUpdateCredentials = Notification.Name("CredentialsControllerDidUpdateCredentials")
    static let credentialsControllerDidFinishRefreshingCredentials = Notification.Name("credentialsControllerDidFinishRefreshingCredentials")
    static let credentialsControllerDidAddCredential = Notification.Name("CredentialsControllerDidAddCredential")
    static let credentialsControllerDidUpdateStatus = Notification.Name("CredentialsControllerDidUpdateStatus")
    static let credentialsControllerDidSupplementInformation = Notification.Name("CredentialsControllerDidSupplementInformation")
    static let credentialsControllerDidError = Notification.Name("CredentialsControllerDidError")
}

final class CredentialsController {
    var credentials: [Credentials] = [] {
        didSet {
            NotificationCenter.default.post(name: .credentialsControllerDidUpdateCredentials, object: nil)
        }
    }
    var user: User? {
        didSet {
            performFetch()
        }
    }

    var updatedCredentials: [Credentials] = []
    private(set) var supplementInformationTask: SupplementInformationTask?

    private(set) var credentialContext = CredentialsContext()
    private var refreshTask: RefreshCredentialTask?
    private var addCredentialTask: AddCredentialsTask?

    func performFetch() {
        credentialContext.fetchCredentialsList(completion: { [weak self] result in
            guard let self = self else { return }
            do {
                let credentials = try result.get()
                self.credentials = credentials
            } catch {
                NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil)
            }
        })
    }

    func performRefresh(_ credentials: Credentials) {
        refreshTask = credentialContext.refresh(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            progressHandler: { [weak self] in self?.refreshProgressHandler(status: $0) },
            completion: { [weak self] in
                self?.refreshCompletionHandler(result: $0)
        })
    }

    func addCredential(_ provider: Provider, form: Form) {
        addCredentialTask = credentialContext.add(
            for: provider,
            form: form,
            progressHandler: { [weak self] in self?.createProgressHandler(for: $0) },
            completion: { [weak self] in self?.createCompletionHandler(result: $0) }
        )
    }

    func cancelRefresh() {
        refreshTask?.cancel()
    }

    func cancelAddCredential() {
        addCredentialTask?.cancel()
    }

    func deleteCredential(_ credentials: [Credentials]) {
        credentials.forEach { credential in
            credentialContext.delete(credential, completion: { [weak self] result in
                switch result {
                case .success:
                    self?.credentials.removeAll { removedCredential -> Bool in
                        credential.id == removedCredential.id
                    }
                case .failure(let error):
                    let parameters = ["error": error]
                    NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil, userInfo: parameters)
                }
            })
        }
    }

    private func createProgressHandler(for status: AddCredentialsTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
            NotificationCenter.default.post(name: .credentialsControllerDidSupplementInformation, object: nil)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        case .updating(let status):
            let parameters = ["status": status]
            NotificationCenter.default.post(name: .credentialsControllerDidUpdateStatus, object: nil, userInfo: parameters)
        }
    }

    private func createCompletionHandler(result: Result<Credentials, Error>) {
        do {
            let credential = try result.get()
            credentials.append(credential)
            NotificationCenter.default.post(name: .credentialsControllerDidAddCredential, object: nil)
        } catch {
            let parameters = ["error": error]
            NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil, userInfo: parameters)
        }
    }

    private func refreshProgressHandler(status: RefreshCredentialTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
            NotificationCenter.default.post(name: .credentialsControllerDidSupplementInformation, object: nil)
        case .awaitingThirdPartyAppAuthentication(_, let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        case .updating(let credential, _):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                credentials[index] = credential
                let parameters = ["credential": credential]
                NotificationCenter.default.post(name: .credentialsControllerDidUpdateStatus, object: nil, userInfo: parameters)
            }
        case .sessionExpired(let credential):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                credentials[index] = credential
            }
        case .updated(let credential):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                credentials[index] = credential
                updatedCredentials.append(credential)
                let parameters = ["credential": credential]
                NotificationCenter.default.post(name: .credentialsControllerDidUpdateStatus, object: nil, userInfo: parameters)
            }
        case .error(let credential, _):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                credentials[index] = credential
            }
        }
    }

    private func refreshCompletionHandler(result: Result<Credentials, Error>) {
        do {
            let updatedCredentials = try result.get()
            if let index = credentials.firstIndex (where: { $0.id == updatedCredentials.id }) {
                credentials[index] = updatedCredentials
            }
            NotificationCenter.default.post(name: .credentialsControllerDidFinishRefreshingCredentials, object: nil)
        } catch {
            let parameters = ["error": error]
            NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil, userInfo: parameters)
        }
        updatedCredentials = []
    }
}
