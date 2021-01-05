import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider
    @State private var form: TinkLink.Form
    @State private var error: IdentifiableError?
    @State private var isLoading = false

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    init(provider: Provider) {
        self.provider = provider
        self._form = State(initialValue: TinkLink.Form(provider: provider))
    }

    private func formField(for field: TinkLink.Form.Field, at fieldIndex: Int) -> some View {
        Section(header: Text(field.attributes.description), footer: Text(field.attributes.helpText ?? "")) {
            if field.attributes.isSecureTextEntry {
                SecureField(field.attributes.placeholder ?? "", text: $form.fields[fieldIndex].text)
            } else {
                TextField(field.attributes.placeholder ?? "", text: $form.fields[fieldIndex].text)
                    .autocapitalization(.none)
            }
        }
    }

    var body: some View {
        SwiftUI.Form {
            ForEach(Array(zip(form.fields.indices, form.fields)), id: \.1.name) { (fieldIndex, field) in
                formField(for: field, at: fieldIndex)
                Section(footer: Text(provider.helpText ?? "")) {
                    if isLoading {
                        ProgressView()
                    }
                }
            }
        }
        .navigationTitle(provider.displayName)
        .toolbar(content: {
            ToolbarItem {
                Button("Add") {
                    isLoading = true
                    credentialsController.addCredentials(for: provider, form: form) { result in
                        isLoading = false
                        do {
                            let credentials = try result.get()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            self.error = IdentifiableError(error: error)
                        }
                    }
                }
                .disabled(!form.areFieldsValid || isLoading)
            }
        })
        .sheet(item: $credentialsController.supplementInformationTask) { task in
            SupplementalInformationForm(supplementInformationTask: task) { result in
                credentialsController.supplementInformationTask = nil
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text(error.error.localizedDescription), dismissButton: .default(Text("OK")))
        }
    }
}
