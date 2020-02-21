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
            self.userController.authenticateUser(accessToken: AccessToken(rawValue: <#String#>)!) { result in
                do {
                    let user = try result.get()
                    self.credentialController.user = user
                    self.providerController.user = user
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
