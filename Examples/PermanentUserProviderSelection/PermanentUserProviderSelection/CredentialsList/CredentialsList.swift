import SwiftUI
import TinkLink

struct CredentialsList: View {
    @ObservedObject var credentialsController: CredentialsController
    @ObservedObject var providerController: ProviderController

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm MMM dd, yyyy"
        return formatter
    }()

    var body: some View {
        List {
            Section {
                ForEach(credentialsController.credentials) { credentials in
                    NavigationLink(destination: CredentialsDetailView(credentials: credentials, provider: self.providerController.provider(providerID: credentials.providerID))) {
                        CredentialsListRow(
                            providerName: self.providerController.provider(providerID: credentials.providerID)?.displayName ?? "",
                            updatedDate: (self.dateFormatter.string(from: credentials.updated ?? Date()))
                        )
                    }
                }
                .onDelete { indexSet in
                    let credentialsToDelete = indexSet.map { self.credentialsController.credentials[$0] }
                    self.credentialsController.deleteCredentials(credentials: credentialsToDelete)
                    self.credentialsController.credentials.remove(atOffsets: indexSet)
                }
            }
            Section {
                AddCredentialsRow(credentialsController: credentialsController, providerController: providerController)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct CredentialsListRow_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsList(credentialsController: CredentialsController(), providerController: ProviderController())
    }
}
