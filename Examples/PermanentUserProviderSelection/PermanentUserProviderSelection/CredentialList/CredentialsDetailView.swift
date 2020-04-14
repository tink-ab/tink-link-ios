import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    let credentials: Credentials

    var body: some View {
        Form {
            Section(footer: Text(credentials.statusPayload)) {
                Text(String(describing: credentials.status).localizedCapitalized)
            }
            Button(action: refresh) {
                Text("Refresh")
            }
        }
        .navigationBarTitle("Credentials", displayMode: .inline)
    }

    private func refresh() {

    }
}
