import SwiftUI
import TinkLink

struct AddCredentialRow: View {
    @ObservedObject var credentialController: CredentialController
    @ObservedObject var providerController: ProviderController

    @State var shouldShowProviders: Bool = false

    var body: some View {
        return Group {
            if !providerController.providers.isEmpty {
                Button(action: {
                    self.shouldShowProviders = true
                }) {
                    Text("Add New Credentials")
                }
                .sheet(isPresented: $shouldShowProviders, content: {
                    AddCredentialFlowView(providers: self.providerController.providers, credentialController: self.credentialController) { _ in
                        self.credentialController.performFetch()
                    }
                })
            }
        }
    }
}

struct AddCredentialRow_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialRow(credentialController: CredentialController(), providerController: ProviderController())
    }
}
