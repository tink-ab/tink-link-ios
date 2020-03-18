import SwiftUI
import TinkLink

struct RefreshCredentialList: View {
    var credentials: [Credentials]
    var updatedCredentials: [Credentials]

    @ObservedObject var providerController: ProviderController

    @Binding private(set) var selectedCredentials: [Credentials]

    var body: some View {
        Group {
            ForEach(credentials) { credential -> RefreshCredentialListRow in
                // Custom binding
                let binding = Binding(
                    get: { self.selectedCredentials.contains { $0.id == credential.id } },
                    set: { $0 ? self.selectedCredentials.append(credential) : self.selectedCredentials.removeAll { $0.id == credential.id } }
                )
                var viewState: RefreshCredentialListRow.ViewState {
                    guard !self.updatedCredentials.contains(where: { $0.id == credential.id}) else { return .updated }
                    switch credential.status {
                    case .updating, .awaitingMobileBankIDAuthentication, .awaitingSupplementalInformation, .awaitingThirdPartyAppAuthentication:
                        return .updating
                    case .permanentError, .temporaryError, .authenticationError, .sessionExpired:
                        return .error
                    default:
                        return .selection
                    }
                }
                return RefreshCredentialListRow(provider: self.providerController.provider(providerID: credential.providerID), viewState: viewState, isSelected: binding)
            }
        }
    }
}

struct RefreshCredentialList_Previews: PreviewProvider {
    static var previews: some View {
        RefreshCredentialList(credentials: [], updatedCredentials: [], providerController: ProviderController(), selectedCredentials: Binding<[Credentials]>.constant([]))
    }
}
