import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider

    @State private var form: TinkLink.Form
    @State private var failure: Failure?
    @State private var isLoading = false

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    init(provider: Provider) {
        self.provider = provider
        self._form = State(initialValue: TinkLink.Form(provider: provider))
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
        .navigationTitle(provider.displayName)
        .toolbar(content: {
            ToolbarItem {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Add") {
                        isLoading = true
                        credentialsController.addCredentials(for: provider, form: form) { result in
                            isLoading = false
                            do {
                                _ = try result.get()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                self.failure = Failure(error: error)
                            }
                        }
                    }
                    .disabled(!form.areFieldsValid)
                }
            }
        })
        .sheet(item: $credentialsController.supplementInformationTask) { task in
            SupplementalInformationForm(supplementInformationTask: task)
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
