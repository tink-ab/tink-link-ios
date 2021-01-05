import SwiftUI
import TinkLink

struct UpdateCredentialsFlowView: View {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler

    private let provider: Provider
    private let credentials: Credentials

    @State private var form: TinkLink.Form
    @State private var failure: Failure?
    @State private var isLoading = false

    @EnvironmentObject var credentialsController: CredentialsController

    init(provider: Provider, credentials: Credentials, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.provider = provider
        self.credentials = credentials
        self._form = State(initialValue: TinkLink.Form(updatingCredentials: credentials, provider: provider))
    }

    var body: some View {
        SwiftUI.Form {
            ForEach(Array(zip(form.fields.indices, form.fields)), id: \.1.name) { (fieldIndex, field) in
                FormField(field: $form.fields[fieldIndex])
            }
            Section(footer: provider.helpText.map(Text.init)) {
                EmptyView()
            }
        }
        .navigationBarTitle(provider.displayName, displayMode: .inline)
        .toolbar(content: {
            ToolbarItem {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Add") {
                        isLoading = true
                        credentialsController.addCredentials(for: provider, form: form) { result in
                            isLoading = false
                            onCompletion(result)
                        }
                    }
                    .disabled(!form.areFieldsValid)
                }
            }
        })
        .sheet(item: $credentialsController.supplementInformationTask) { task in
            SupplementalInformationForm(supplementInformationTask: task) { result in
                credentialsController.supplementInformationTask = nil
            }
        }
        .alert(item: $failure) { failure in
            if let tinLinkError = failure.error as? TinkLinkError, let reason = tinLinkError.thirdPartyAppAuthenticationFailureReason, reason.code == .downloadRequired, let appStoreURL = reason.appStoreURL {
                return Alert(
                    title: Text(reason.errorDescription ?? tinLinkError.localizedDescription),
                    message: reason.failureReason.map(Text.init),
                    primaryButton: .default(Text("Download"), action: {
                        UIApplication.shared.open(appStoreURL)
                    }),
                    secondaryButton: .cancel()
                )
            } else if let localizedError = failure as? LocalizedError {
                return Alert(
                    title: Text(localizedError.errorDescription ?? localizedError.localizedDescription),
                    message: localizedError.failureReason.map(Text.init),
                    dismissButton: .default(Text("OK"))
                )
            } else {
                return Alert(title: Text(failure.error.localizedDescription), dismissButton: .default(Text("OK")))
            }
        }
    }
}
