import SwiftUI
import TinkLink

struct ContentView: View {

    @ObservedObject var credentialController = CredentialsController()
    @ObservedObject var providerController = ProviderController()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm MMM dd, yyyy"
        return formatter
    }()

    var body: some View {
        NavigationView {
            CredentialsView(credentialsController: credentialsController, providerController: providerController)
        }.onAppear {
            Tink.shared.setCredential(.accessToken("YOUR_ACCESS_TOKEN"))
            self.credentialsController.performFetch()
            self.providerController.performFetch()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(credentialsController: CredentialsController(), providerController: ProviderController())
    }
}
