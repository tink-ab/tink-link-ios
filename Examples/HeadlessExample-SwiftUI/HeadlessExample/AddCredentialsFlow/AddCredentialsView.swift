import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider
    @State private var form: TinkLink.Form
    @State private var error: IdentifiableError?

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    init(provider: Provider) {
        self.provider = provider
        self._form = State(initialValue: TinkLink.Form(provider: provider))
    }

    var body: some View {
        SwiftUI.Form {
            Section {
                ForEach(Array(zip(form.fields.indices, form.fields)), id: \.1.name) { (fieldIndex, field) in
                    if field.attributes.isSecureTextEntry {
                        SecureField(field.attributes.description, text: $form.fields[fieldIndex].text)
                    } else {
                        TextField(field.attributes.description, text: $form.fields[fieldIndex].text)
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                }
            }
        }
        .navigationTitle(provider.displayName)
        .toolbar(content: {
            ToolbarItem {
                Button("Add") {
                    credentialsController.addCredentials(for: provider, form: form) { result in
                        do {
                            let credentials = try result.get()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            self.error = IdentifiableError(error: error)
                        }
                    }
                }
                .disabled(!form.areFieldsValid)
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
