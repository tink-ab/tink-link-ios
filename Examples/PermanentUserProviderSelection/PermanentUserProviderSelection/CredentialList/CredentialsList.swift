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
                ForEach(credentialsController.credentials) { credential in
                    CredentialListRow(
                        providerName: self.providerController.provider(providerID: credential.providerID)?.displayName ?? "",
                        updatedDate: (self.dateFormatter.string(from: credential.updated ?? Date())))
                }.onDelete { indexSet in
                    let credentialsToDelete = indexSet.map { self.credentialsController.credentials[$0] }
                    self.credentialsController.deleteCredential(credentials: credentialsToDelete)
                    self.credentialsController.credentials.remove(atOffsets: indexSet)
                }
            }
            Section {
                AddCredentialRow(credentialsController: credentialsController, providerController: providerController)
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
