import TinkLink
import SwiftUI

final class CredentialController: ObservableObject {
    @Published var credentials: [Credentials] = []

    @Published var updatedCredentials: [Credentials] = []
    @Published var supplementInformationTask: SupplementInformationTask?

    private(set) var credentialContext =  CredentialsContext()
    private var task: RefreshCredentialTask?
    
    func performFetch() {
        credentialContext.fetchCredentialsList(completion: { [weak self] result in
            do {
                let credentials = try result.get()
                DispatchQueue.main.async {
                    self?.credentials = credentials
                }
            } catch {
                // Handle any errors
            }
        })
    }

    func performRefresh(credentials: [Credentials], completion: @escaping (Result<[Credentials], Error>) -> Void) {
        task = credentialContext.refresh(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            progressHandler: { [weak self] in
                self?.refreshProgressHandler(status: $0)
            },
            completion: { [weak self] result in
                self?.refreshCompletionHandler(result: result)
                completion(result)
        })
    }

    func cancelRefresh() {
        task?.cancel()
    }

    func deleteCredential(credentials: [Credentials]) {
        credentials.forEach { credential in
            credentialContext.delete(credential, completion: { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.credentials.removeAll { removedCredential -> Bool in
                            credential.id == removedCredential.id
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }

    private func refreshProgressHandler(status: RefreshCredentialTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
        case .awaitingThirdPartyAppAuthentication(_, let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        case .updating(let credential, _):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = credential
                }
            }
        case .sessionExpired(let credential):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = credential
                }
            }
        case .updated(let credential):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = credential
                    self?.updatedCredentials.append(credential)
                }
            }
        case .error(let credential, _):
            if let index = credentials.firstIndex (where: { $0.id == credential.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = credential
                }
            }
        }
    }

    private func refreshCompletionHandler(result: Result<[Credentials], Error>) {
        do {
            let updatedCredentials = try result.get()
            var groupedCredentials = Dictionary(grouping: credentials) { $0.id }
            let groupedUpdatedCredentials = Dictionary(grouping: updatedCredentials) { $0.id }
            groupedCredentials.merge(groupedUpdatedCredentials) { (_, new) in return new }
            DispatchQueue.main.async { [weak self] in
                self?.credentials = groupedCredentials.values.flatMap { $0 }
            }
        } catch {
            // Handle any errors
        }
        DispatchQueue.main.async { [weak self] in
            self?.updatedCredentials = []
        }
    }
}
