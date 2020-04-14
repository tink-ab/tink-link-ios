import SwiftUI
import TinkLink

struct ContentView: View {
    @ObservedObject var userController = UserController()
    @ObservedObject var credentialsController = CredentialsController()
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
            self.userController.authenticateUser(accessToken: AccessToken(rawValue: "YOUR_ACCESS_TOKEN")!) { result in
                do {
                    let user = try result.get()
                    self.credentialsController.performFetch()
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
        ContentView(credentialsController: CredentialsController(), providerController: ProviderController())
    }
}
