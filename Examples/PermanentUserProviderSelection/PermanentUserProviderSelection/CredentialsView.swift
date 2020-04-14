import SwiftUI
import TinkLink

struct CredentialsView: View {
    @EnvironmentObject var credentialsController: CredentialController
    @EnvironmentObject var providerController: ProviderController

    var body: some View {
        CredentialsList()
            .navigationBarTitle("Credentials")
            .sheet(item: Binding(get: { self.credentialsController.supplementInformationTask }, set: { self.credentialsController.supplementInformationTask = $0 })) {
                SupplementControllerRepresentableView(supplementInformationTask: $0) { _ in }
            }
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
