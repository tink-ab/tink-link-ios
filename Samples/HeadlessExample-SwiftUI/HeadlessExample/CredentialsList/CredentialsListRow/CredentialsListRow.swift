import SwiftUI
import TinkLink

struct CredentialsListRow: View {
    var providerName: String
    var updatedDate: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(providerName)
            Text("Updated \(updatedDate)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

struct CredentialListRow_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsListRow(providerName: "Foo", updatedDate: "bar")
    }
}
