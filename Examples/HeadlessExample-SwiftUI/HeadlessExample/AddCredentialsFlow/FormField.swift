import SwiftUI
import TinkLink

struct FormField: View {
    @Binding var field: TinkLink.Form.Field

    var body: some View {
        Section(header: Text(field.attributes.description), footer: field.attributes.helpText.map(Text.init)) {
            if field.attributes.isSecureTextEntry {
                SecureField(field.attributes.placeholder ?? "", text: $field.text)
            } else {
                TextField(field.attributes.placeholder ?? "", text: $field.text)
                    .autocapitalization(.none)
            }
        }
    }
}
