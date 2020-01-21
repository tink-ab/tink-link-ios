import SwiftUI
import TinkLinkSDK

struct CredentialsList: View {
    @ObservedObject var credentialController: CredentialController
    @ObservedObject var providerController: ProviderController

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm MMM dd, yyyy"
        return formatter
    }()

    var body: some View {
        List {
            Section {
                ForEach(credentialController.credentials) { credential in
                    CredentialListRow(
                        providerName: self.providerController.provider(providerID: credential.providerID)?.displayName ?? "",
                        updatedDate: (self.dateFormatter.string(from: credential.updated ?? Date())))
                }.onDelete { indexSet in
                    let credentialsToDelete = indexSet.map { self.credentialController.credentials[$0] }
                    self.credentialController.deleteCredential(credentials: credentialsToDelete)
                    self.credentialController.credentials.remove(atOffsets: indexSet)
                }
            }
            Section {
                AddCredentialRow(credentialController: credentialController, providerController: providerController)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct CredentialsListRow_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsList(credentialController: CredentialController(), providerController: ProviderController())
    }
}
