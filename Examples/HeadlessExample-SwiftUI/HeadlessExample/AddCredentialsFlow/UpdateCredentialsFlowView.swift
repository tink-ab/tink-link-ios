import SwiftUI
import TinkLink

struct UpdateCredentialsFlowView: View {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler

    private let provider: Provider
    private let credentials: Credentials
    private let credentialsController: CredentialsController

    init(provider: Provider, credentials: Credentials, credentialsController: CredentialsController, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.provider = provider
        self.credentials = credentials
        self.credentialsController = credentialsController
    }

    var body: some View {
        EmptyView()
    }
}
