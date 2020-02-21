import SwiftUI
import TinkLink

struct CredentialsView: View {
    @ObservedObject var credentialController: CredentialController
    @ObservedObject var providerController: ProviderController

    @State private var isPresentingRefreshAlert = false
    @State private var isAnimating: Bool = false
    @State private var selectedCredentials: [Credential] = []
    @State private var isRefreshing = false

    var body: some View {
        return Group {
            if credentialController.credentialContext == nil {
                ActivityIndicator(isAnimating: $isAnimating, style: .large)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear { self.isAnimating = true }
                    .onDisappear { self.isAnimating = false }
            } else {
                CredentialsList(credentialController: credentialController, providerController: providerController)
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
                            RefreshCredentialList(credentials: self.credentialController.credentials, updatedCredentials: self.credentialController.updatedCredentials, providerController: self.providerController, selectedCredentials: self.$selectedCredentials)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                                .onAppear(perform: {
                                    self.selectedCredentials = self.credentialController.credentials
                                })
                                .disabled(isRefreshing)
                        },
                        dismissButton: .cancel(Text("Cancel"), action: {
                            self.isRefreshing = false
                            self.isPresentingRefreshAlert = false
                            self.credentialController.cancelRefresh()
                        }),
                        primaryButton: .default(Text("Update"), enabled: !selectedCredentials.isEmpty, action: {
                            self.isRefreshing = true
                            self.credentialController.performRefresh(credentials: self.selectedCredentials) { _ in
                                self.isRefreshing = false
                                self.isPresentingRefreshAlert = false
                            }
                        })
                    )
                }
                .sheet(item: Binding(get: { self.credentialController.supplementInformationTask }, set: { self.credentialController.supplementInformationTask = $0 })) {
                    SupplementControllerRepresentableView(supplementInformationTask: $0) { _ in }
                }
            }
        }
    }
}

struct CredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(credentialController: CredentialController(), providerController: ProviderController())
    }
}
