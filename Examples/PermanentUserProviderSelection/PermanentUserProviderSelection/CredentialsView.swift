import SwiftUI
import TinkLink

struct CredentialsView: View {
    @EnvironmentObject var credentialsController: CredentialController
    @EnvironmentObject var providerController: ProviderController

    @State private var isPresentingRefreshAlert = false
    @State private var isAnimating: Bool = false
    @State private var selectedCredentials: Credentials?
    @State private var isRefreshing = false

    var body: some View {
        return Group {
            if credentialsController.credentialsContext == nil {
                ActivityIndicator(isAnimating: $isAnimating, style: .large)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear { self.isAnimating = true }
                    .onDisappear { self.isAnimating = false }
            } else {
                CredentialsList()
                    .disabled(isPresentingRefreshAlert)
                    .navigationBarTitle("Credentials")
                .sheet(item: Binding(get: { self.credentialsController.supplementInformationTask }, set: { self.credentialsController.supplementInformationTask = $0 })) {
                    SupplementControllerRepresentableView(supplementInformationTask: $0) { _ in }
                }
            }
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
