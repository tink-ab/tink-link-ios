import SwiftUI
import TinkLink

struct ContentView: View {
    @ObservedObject var credentialController = CredentialController()
    @ObservedObject var providerController = ProviderController()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm MMM dd, yyyy"
        return formatter
    }()

    var body: some View {
        NavigationView {
            CredentialsView(credentialController: credentialController, providerController: providerController)
        }.onAppear {
            Tink.shared.setCredential(.accessToken("YOUR_ACCESS_TOKEN"))
            self.credentialController.performFetch()
            self.providerController.performFetch()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(credentialController: CredentialController(), providerController: ProviderController())
    }
}
