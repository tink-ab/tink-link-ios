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
                    ProviderPicker(providers: self.providerController.providers)
                        .environmentObject(credentialsController)
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
