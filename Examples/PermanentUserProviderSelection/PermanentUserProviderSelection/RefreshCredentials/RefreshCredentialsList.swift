import SwiftUI
import TinkLink

struct RefreshCredentialsList: View {
    var credentials: [Credentials]
    var updatedCredentials: [Credentials]

    @ObservedObject var providerController: ProviderController

    @Binding private(set) var selectedCredentials: Credentials?

    var body: some View {
        Group {
            ForEach(credentials) { credentials -> RefreshCredentialsListRow in
                // Custom binding
                let binding = Binding(
                    get: { self.selectedCredentials?.id == credentials.id },
                    set: { self.selectedCredentials = $0 ? credentials : nil }
                )
                var viewState: RefreshCredentialsListRow.ViewState {
                    guard !self.updatedCredentials.contains(where: { $0.id == credentials.id}) else { return .updated }
                    switch credentials.status {
                    case .updating, .awaitingMobileBankIDAuthentication, .awaitingSupplementalInformation, .awaitingThirdPartyAppAuthentication:
                        return .updating
                    case .permanentError, .temporaryError, .authenticationError, .sessionExpired:
                        return .error
                    default:
                        return .selection
                    }
                }
                return RefreshCredentialsListRow(provider: self.providerController.provider(providerID: credentials.providerID), viewState: viewState, isSelected: binding)
            }
        }
    }
}

struct RefreshCredentialsList_Previews: PreviewProvider {
    static var previews: some View {
        RefreshCredentialsList(credentials: [], updatedCredentials: [], providerController: ProviderController(), selectedCredentials: Binding<Credentials?>.constant(nil))
    }
}
