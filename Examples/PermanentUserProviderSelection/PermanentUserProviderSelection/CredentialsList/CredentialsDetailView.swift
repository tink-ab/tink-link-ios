import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    @EnvironmentObject var credentialsController: CredentialsController

    let credentials: Credentials
    let provider: Provider?

    @State private var isRefreshing = false

    private var updatedCredentials: Credentials {
        credentialsController.credentials.first(where: { $0.id == credentials.id }) ?? credentials
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var body: some View {
        Form {
            Section(footer: Text(updatedCredentials.statusPayload)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(describing: updatedCredentials.status).localizedCapitalized)
                    updatedCredentials.statusUpdated.map {
                        Text("\($0, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Button(action: refresh) {
                Text("Refresh")
            }
            .disabled(isRefreshing)
        }
        .navigationBarTitle(Text(provider?.displayName ?? "Credentials"), displayMode: .inline)
        .sheet(item: .init(get: { self.credentialsController.supplementInformationTask }, set: { self.credentialsController.supplementInformationTask = $0 })) { (task) in
            SupplementalInformationForm(supplementInformationTask: task) { (result) in
                self.credentialsController.supplementInformationTask = nil
            }
        }
    }

    private func refresh() {
        isRefreshing = true
        credentialsController.performRefresh(credentials: credentials) { (result) in
            self.isRefreshing = false
        }
    }
}
