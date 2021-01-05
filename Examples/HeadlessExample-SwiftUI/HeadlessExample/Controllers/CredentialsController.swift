import TinkLink
import SwiftUI

final class CredentialsController: ObservableObject {
    @Published var credentials: [Credentials] = []

    @Published var supplementInformationTask: SupplementInformationTask?

    private(set) var credentialsContext = Tink.shared.credentialsContext
    private var task: Cancellable?

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
            authenticationHandler: { [weak self] authentication in
                self?.handleAuthentication(authentication)
            },
            progressHandler: { status in
                DispatchQueue.main.async {
                    self.supplementInformationTask = nil
                }
            },
            completion: { [weak self] result in
                self?.refreshCompletionHandler(result: result)
                completion(result)
                DispatchQueue.main.async {
                    self?.supplementInformationTask = nil
                    if case .success(let credentials) = result, let index = self?.credentials.firstIndex(where: { $0.id == credentials.id }) {
                        self?.credentials[index] = credentials
                    }
                }
            }
        )
    }

    func performAuthentication(credentials: Credentials, completion: @escaping (Result<Credentials, Error>) -> Void) {
        task = credentialsContext.authenticate(
            credentials,
            shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
            authenticationHandler: { [weak self] authentication in
                self?.handleAuthentication(authentication)
            }, completion: { [weak self] result in
                self?.refreshCompletionHandler(result: result)
                completion(result)
                DispatchQueue.main.async {
                    if case .success(let credentials) = result, let index = self?.credentials.firstIndex(where: { $0.id == credentials.id }) {
                        self?.credentials[index] = credentials
                    }
                }
            }
        )
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
                        self?.credentials.removeAll { $0.id == credentials.id }
                    }
                } catch {
                    // Handle any errors
                }
            })
        }
    }

    func addCredentials(for provider: Provider, form: TinkLink.Form, completion: @escaping (Result<Credentials, Error>) -> Void) {
        credentialsContext.add(for: provider, form: form) { [weak self] task in
            DispatchQueue.main.async {
                self?.handleAuthentication(task)
            }
        } progressHandler: { [weak self] status in
            DispatchQueue.main.async {
                self?.supplementInformationTask = nil
            }
        } completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.supplementInformationTask = nil
                completion(result)
            }
        }
    }

    func updateCredentials(_ credentials: Credentials, form: TinkLink.Form, completion: @escaping (Result<Credentials, Error>) -> Void) {
        credentialsContext.update(credentials, form: form) { [weak self] task in
            DispatchQueue.main.async {
                self?.handleAuthentication(task)
            }
        } progressHandler: { [weak self] status in
            DispatchQueue.main.async {
                self?.supplementInformationTask = nil
            }
        } completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.supplementInformationTask = nil
                completion(result)
            }
        }
    }

    private func handleAuthentication(_ authentication: AuthenticationTask) {
        switch authentication {
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.supplementInformationTask = supplementInformationTask
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            thirdPartyAppAuthenticationTask.handle()
        }
    }

    private func refreshCompletionHandler(result: Result<Credentials, Error>) {
        do {
            let updatedCredentials = try result.get()
            if let index = credentials.firstIndex(where: { $0.id == updatedCredentials.id }) {
                DispatchQueue.main.async { [weak self] in
                    self?.credentials[index] = updatedCredentials
                }
            }
        } catch {
            // Handle any errors
        }
    }
}
