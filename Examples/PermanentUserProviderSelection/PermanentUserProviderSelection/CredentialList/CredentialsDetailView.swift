import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    let credentials: Credentials
    let provider: Provider?

    var body: some View {
        Form {
            Section(footer: Text(credentials.statusPayload)) {
                Text(String(describing: credentials.status).localizedCapitalized)
            }
            Button(action: refresh) {
                Text("Refresh")
            }
        }
        .navigationBarTitle(Text(provider?.displayName ?? "Credentials"), displayMode: .inline)
    }

    private func refresh() {

    }
}
