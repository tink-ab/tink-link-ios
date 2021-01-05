import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider
    @State private var form: TinkLink.Form

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    init(provider: Provider) {
        self.provider = provider
        self._form = State(initialValue: TinkLink.Form(provider: provider))
    }

    var body: some View {
        SwiftUI.Form {
            Section {
                ForEach(form.fields, id: \.name) { field in
                    if field.attributes.isSecureTextEntry {
                        SecureField(field.attributes.description, text: .constant(field.text))
                    } else {
                        TextField(field.attributes.description, text: .constant(field.text))
                    }
                }
            }
            Section {
                Button("Add") {

                }
            }
        }
        .navigationTitle(provider.displayName)
    }
}
