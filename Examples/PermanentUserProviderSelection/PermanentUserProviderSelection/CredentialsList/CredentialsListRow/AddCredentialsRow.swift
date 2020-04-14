import SwiftUI
import TinkLink

struct AddCredentialsRow: View {
    @ObservedObject var credentialsController: CredentialsController
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
                    AddCredentialFlowView(providers: self.providerController.providers, credentialsController: self.credentialsController) { _ in
                        self.credentialsController.performFetch()
                    }
                })
            }
        }
    }
}

struct AddCredentialsRow_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialsRow(credentialsController: CredentialsController(), providerController: ProviderController())
    }
}
