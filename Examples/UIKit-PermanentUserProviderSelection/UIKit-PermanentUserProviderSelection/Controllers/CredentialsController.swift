import TinkLink
import Foundation

extension Notification.Name {
    static let credentialsControllerDidUpdateCredentials = Notification.Name("CredentialsControllerDidUpdateCredentials")
    static let credentialsControllerDidFinishRefreshingCredentials = Notification.Name("CredentialsControllerDidFinishRefreshingCredentials")
    static let credentialsControllerDidAddCredential = Notification.Name("CredentialsControllerDidAddCredential")
    static let credentialsControllerDidUpdateStatus = Notification.Name("CredentialsControllerDidUpdateStatus")
    static let credentialsControllerDidSupplementInformation = Notification.Name("CredentialsControllerDidSupplementInformation")
    static let credentialsControllerDidError = Notification.Name("CredentialsControllerDidError")
}

final class CredentialsController {
    var credentialsList: [Credentials] = [] {
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

    private(set) var credentialsContext = CredentialsContext()
    private var refreshTask: RefreshCredentialsTask?
    private var addCredentialsTask: AddCredentialsTask?

    func performFetch() {
        credentialsContext.fetchCredentialsList(completion: { [weak self] result in
            guard let self = self else { return }
            do {
                let credentials = try result.get()
                self.credentialsList = credentials
            } catch {
                NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil)
            }
        })
    }

    func performRefresh(_ credentials: Credentials) {
        refreshTask = credentialsContext.refresh(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            progressHandler: { [weak self] in self?.refreshProgressHandler(status: $0) },
            completion: { [weak self] in
                self?.refreshCompletionHandler(result: $0)
        })
    }

    func addCredential(_ provider: Provider, form: Form) {
        addCredentialsTask = credentialsContext.add(
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
        addCredentialsTask?.cancel()
    }

    func deleteCredential(_ credentials: [Credentials]) {
        credentials.forEach { credential in
            credentialsContext.delete(credential, completion: { [weak self] result in
                switch result {
                case .success:
                    self?.credentialsList.removeAll { removedCredential -> Bool in
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
            credentialsList.append(credential)
            NotificationCenter.default.post(name: .credentialsControllerDidAddCredential, object: nil)
        } catch {
            let parameters = ["error": error]
            NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil, userInfo: parameters)
        }
    }

    private func refreshProgressHandler(status: RefreshCredentialsTask.Status) {
        guard let credential = refreshTask?.credentials else { return }
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
            NotificationCenter.default.post(name: .credentialsControllerDidSupplementInformation, object: nil)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        case .updating:
            if let index = credentialsList.firstIndex (where: { $0.id == credential.id }) {
                credentialsList[index] = credential
                let parameters = ["credential": credential]
                NotificationCenter.default.post(name: .credentialsControllerDidUpdateStatus, object: nil, userInfo: parameters)
            }
        case .sessionExpired:
            if let index = credentialsList.firstIndex (where: { $0.id == credential.id }) {
                credentialsList[index] = credential
            }
        case .updated:
            if let index = credentialsList.firstIndex (where: { $0.id == credential.id }) {
                credentialsList[index] = credential
                updatedCredentials.append(credential)
                let parameters = ["credential": credential]
                NotificationCenter.default.post(name: .credentialsControllerDidUpdateStatus, object: nil, userInfo: parameters)
            }
        case .error:
            if let index = credentialsList.firstIndex (where: { $0.id == credential.id }) {
                credentialsList[index] = credential
            }
        }
    }

    private func refreshCompletionHandler(result: Result<Credentials, Error>) {
        do {
            let updatedCredentials = try result.get()
            if let index = credentialsList.firstIndex (where: { $0.id == updatedCredentials.id }) {
                credentialsList[index] = updatedCredentials
            }
            NotificationCenter.default.post(name: .credentialsControllerDidFinishRefreshingCredentials, object: nil)
        } catch {
            let parameters = ["error": error]
            NotificationCenter.default.post(name: .credentialsControllerDidError, object: nil, userInfo: parameters)
        }
        updatedCredentials = []
    }
}
