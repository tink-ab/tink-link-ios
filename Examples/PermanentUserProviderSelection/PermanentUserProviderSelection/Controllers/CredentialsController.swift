import TinkLink
import SwiftUI

final class CredentialsController: ObservableObject {
    @Published var credentials: [Credentials] = []

    @Published var supplementInformationTask: SupplementInformationTask?

    private(set) var credentialsContext =  CredentialsContext()
    private var task: RefreshCredentialsTask?
    
    func performFetch() {
        credentialsContext.fetchCredentialsList(completion: { [weak self] result in
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

    func performRefresh(credentials: Credentials, completion: @escaping (Result<Credentials, Error>) -> Void) {
        task = credentialsContext.refresh(
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

    func deleteCredentials(credentials: [Credentials]) {
        credentials.forEach { credentials in
            credentialsContext.delete(credentials, completion: { [weak self] result in
                do {
                    try result.get()
                    DispatchQueue.main.async {
                        self?.credentials.removeAll { removedCredentials -> Bool in
                            credentials.id == removedCredentials.id
                        }
                    }
                } catch {
                    // Handle any errors
                }
            })
        }
    }

    private func refreshProgressHandler(status: RefreshCredentialsTask.Status) {
        guard let refreshedCredentials = task?.credentials else { return }
        switch status {
        case .authenticating:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        case .updating:
            if let index = credentials.firstIndex (where: { $0.id == refreshedCredentials.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = refreshedCredentials
                }
            }
        }
    }

    private func refreshCompletionHandler(result: Result<Credentials, Error>) {
        do {
            let updatedCredentials = try result.get()
            if let index = credentials.firstIndex (where: { $0.id == updatedCredentials.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = updatedCredentials
                }
            }
        } catch {
            // Handle any errors
        }
    }
}
