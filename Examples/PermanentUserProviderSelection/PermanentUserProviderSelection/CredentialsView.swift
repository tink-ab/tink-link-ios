import SwiftUI
import TinkLink

struct CredentialsView: View {
    @EnvironmentObject var credentialsController: CredentialController
    @EnvironmentObject var providerController: ProviderController

    var body: some View {
        CredentialsList()
            .navigationBarTitle("Credentials")
            .onAppear {
                self.credentialsController.performFetch()
                self.providerController.performFetch()
            }
    }
}

struct CredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView()
            .environmentObject(CredentialsController())
            .environmentObject(ProviderController())
    }
}
