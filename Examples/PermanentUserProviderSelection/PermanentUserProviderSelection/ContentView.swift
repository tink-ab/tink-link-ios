import SwiftUI
import TinkLink

struct ContentView: View {
    @ObservedObject var userController = UserController()
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
            self.userController.authenticateUser(accessToken: AccessToken(rawValue: "YOUR_ACCESS_TOKEN")!) { result in
                do {
                    let user = try result.get()
                    self.credentialController.performFetch()
                    self.providerController.performFetch()
                } catch {
                    // Handle any errors
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(credentialController: CredentialController(), providerController: ProviderController())
    }
}
