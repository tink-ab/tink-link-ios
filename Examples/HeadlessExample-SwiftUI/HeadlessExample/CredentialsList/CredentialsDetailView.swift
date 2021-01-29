import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    @EnvironmentObject var credentialsController: CredentialsController

    let credentials: Credentials
    let provider: Provider?

    @State private var isRefreshing = false
    @State private var isAuthenticating = false
    @State private var isUpdating = false
    @State private var isDeleting = false

    private var updatedCredentials: Credentials {
        credentialsController.credentials.first(where: { $0.id == credentials.id }) ?? credentials
    }

    private var canAuthenticate: Bool {
        provider?.accessType == .openBanking
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private var statusMessage: String {
        switch credentials.status {
        case .unknown:
            return "Unknown"
        case .created:
            return "Created"
        case .authenticating:
            return "Authenticating"
        case .updating:
            return "Updating"
        case .updated:
            return "Updated"
        case .temporaryError:
            return "Temporary error"
        case .authenticationError:
            return "Authentication error"
        case .permanentError:
            return "Permanent error"
        case .awaitingMobileBankIDAuthentication:
            return "Awaiting Mobile BankID authentication"
        case .awaitingSupplementalInformation:
            return "Awaiting supplemental information"
        case .deleted:
            return "Deleted"
        case .awaitingThirdPartyAppAuthentication:
            return "Awaiting third-party app authentication"
        case .sessionExpired:
            return "Session expired"
        }
    }

    var body: some View {
        Form {
            Section(footer: Text(updatedCredentials.statusPayload ?? "")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusMessage)
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
            Button(action: update) {
                Text("Update")
            }
            if canAuthenticate {
                Button(action: authenticate) {
                    Text("Authenticate")
                }
                .disabled(isAuthenticating)
            }
            Section {
                Button(action: delete) {
                    Text("Delete")
                }
                .disabled(isDeleting)
                .foregroundColor(.red)
            }
        }
        .navigationBarTitle(Text(provider?.displayName ?? "Credentials"), displayMode: .inline)
        .sheet(item: $credentialsController.supplementInformationTask) { task in
            NavigationView {
                SupplementalInformationForm(supplementInformationTask: task)
            }
        }
        .sheet(isPresented: $isUpdating) {
            NavigationView {
                UpdateCredentialsView(provider: self.provider!, credentials: self.credentials) { result in
                    self.isUpdating = false
                    self.credentialsController.performFetch()
                }
                .environmentObject(credentialsController)
            }
        }
    }

    private func refresh() {
        isRefreshing = true
        credentialsController.performRefresh(credentials: credentials) { result in
            self.isRefreshing = false
        }
    }

    private func update() {
        isUpdating = true
    }

    private func authenticate() {
        isAuthenticating = true
        credentialsController.performAuthentication(credentials: credentials) { result in
            self.isAuthenticating = false
        }
    }

    private func delete() {
        isDeleting = true
        credentialsController.deleteCredentials(credentials: [credentials])
    }
}
