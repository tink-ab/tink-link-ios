import SwiftUI
import TinkLink

struct UpdateCredentialsFlowView: View {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler

    private let provider: Provider
    private let credentials: Credentials

    @EnvironmentObject var credentialsController: CredentialsController

    init(provider: Provider, credentials: Credentials, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.provider = provider
        self.credentials = credentials
    }

    var body: some View {
        EmptyView()
    }
}
