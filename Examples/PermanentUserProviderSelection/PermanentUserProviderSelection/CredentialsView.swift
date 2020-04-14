import SwiftUI
import TinkLink

struct CredentialsView: View {
    @ObservedObject var credentialsController: CredentialsController
    @ObservedObject var providerController: ProviderController

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
                CredentialsList(credentialsController: credentialsController, providerController: providerController)
                    .disabled(isPresentingRefreshAlert)
                    .navigationBarTitle("Credentials")
                    .navigationBarItems(
                        trailing: Button(action: {
                            self.isPresentingRefreshAlert = true
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .padding(.all, 10)
                        }
                )
                .alertView(isPresented: $isPresentingRefreshAlert) {
                    AlertView(
                        title: isRefreshing ? "Updating…" : "Update banks & services",
                        content: {
                            RefreshCredentialsList(credentials: self.credentialsController.credentials, updatedCredentials: self.credentialsController.updatedCredentials, providerController: self.providerController, selectedCredentials: self.$selectedCredentials)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                                .disabled(isRefreshing)
                        },
                        dismissButton: .cancel(Text("Cancel"), action: {
                            self.isRefreshing = false
                            self.isPresentingRefreshAlert = false
                            self.credentialsController.cancelRefresh()
                        }),
                        primaryButton: .default(Text("Update"), enabled: selectedCredentials != nil, action: {
                            self.isRefreshing = true
                            self.credentialsController.performRefresh(credentials: self.selectedCredentials!) { _ in
                                self.isRefreshing = false
                                self.isPresentingRefreshAlert = false
                            }
                        })
                    )
                }
                .sheet(item: Binding(get: { self.credentialsController.supplementInformationTask }, set: { self.credentialsController.supplementInformationTask = $0 })) {
                    SupplementControllerRepresentableView(supplementInformationTask: $0) { _ in }
                }
            }
        }
    }
}

struct CredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(credentialsController: CredentialsController(), providerController: ProviderController())
    }
}
