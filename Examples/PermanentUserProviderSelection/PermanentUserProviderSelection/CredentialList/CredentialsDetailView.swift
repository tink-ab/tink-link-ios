import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    let credentials: Credentials

    var body: some View {
        Form {
            Text(credentials.statusPayload)
            Button(action: refresh) {
                Text("Refresh")
            }
        }
        .navigationBarTitle("Credentials")
    }

    private func refresh() {

    }
}
