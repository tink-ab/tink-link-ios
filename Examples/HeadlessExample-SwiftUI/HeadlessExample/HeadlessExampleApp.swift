import TinkLink
import UIKit
import SwiftUI

@main
struct HeadlessExampleApp: App {
    @StateObject private var credentialsController = CredentialsController()
    @StateObject private var providerController = ProviderController()

    init() {
        let configuration = TinkLinkConfiguration(
            clientID: "YOUR_CLIENT_ID",
            appURI: URL(string: "link-demo://tink")!
        )
        Tink.configure(with: configuration)

        Tink.shared.userSession = .accessToken("YOUR_ACCESS_TOKEN")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(credentialsController)
                .environmentObject(providerController)
        }
    }
}
