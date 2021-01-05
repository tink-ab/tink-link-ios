import SwiftUI
import TinkLink

struct UpdateCredentialsFlowView: View {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler

    private let provider: Provider
    private let credentials: Credentials

    @State private var form: TinkLink.Form

    @EnvironmentObject var credentialsController: CredentialsController

    init(provider: Provider, credentials: Credentials, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.provider = provider
        self.credentials = credentials
        self._form = State(initialValue: TinkLink.Form(updatingCredentials: credentials, provider: provider))
    }

    var body: some View {
        EmptyView()
    }
}
