import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    @EnvironmentObject var credentialController: CredentialController

    let credentials: Credentials
    let provider: Provider?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var body: some View {
        Form {
            Section(footer: Text(credentials.statusPayload)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(describing: credentials.status).localizedCapitalized)
                    credentials.statusUpdated.map {
                        Text("\($0, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Button(action: refresh) {
                Text("Refresh")
            }
        }
        .navigationBarTitle(Text(provider?.displayName ?? "Credentials"), displayMode: .inline)
    }

    private func refresh() {
        credentialController.performRefresh(credentials: credentials) { (result) in
        }
    }
}
