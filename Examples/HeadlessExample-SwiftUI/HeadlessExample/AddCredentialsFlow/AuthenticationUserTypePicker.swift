import SwiftUI
import TinkLink

struct AuthenticationUserTypePicker: View {
    var authenticationUserTypes: [ProviderTree.AuthenticationUserTypeNode]
    var onSelection: (Provider) -> Void

    var body: some View {
        List(authenticationUserTypes, id: \.id) { authenticationUserType in
            NavigationLink(destination: destinationView(for: authenticationUserType, onSelection: onSelection)) {
                AuthenticationUserTypeRow(authenticationUserType: authenticationUserType.authenticationUserType)
            }
        }
        .navigationTitle("Choose Authentication Type")
    }
}

struct AuthenticationUserTypeRow: View {
    var authenticationUserType: Provider.AuthenticationUserType

    var body: some View {
        switch authenticationUserType {
        case .personal:
            Text("Personal")
        case .business:
            Text("Business")
        case .corporate:
            Text("Corporate")
        case .unknown:
            Text("Unknown")
        }
    }
}

// TODO: Move this to Core
extension ProviderTree.AuthenticationUserTypeNode: Identifiable {
    public var id: String {
        switch authenticationUserType {
        case .personal: return "personal"
        case .business: return "business"
        case .corporate: return "corporate"
        case .unknown: return "unknown"
        }
    }
}

struct AuthenticationUserTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationUserTypePicker(authenticationUserTypes: [], onSelection: { _ in })
    }
}

@ViewBuilder
func destinationView(for authenticationUserType: ProviderTree.AuthenticationUserTypeNode, onSelection: @escaping (Provider) -> Void) -> some View {
    switch authenticationUserType {
    case .provider(let provider):
        Button(action: { onSelection(provider) }) {
            Text(provider.displayName)
        }
    case .credentialsKinds(let credentialsKinds):
        CredentialsKindPicker(credentialsKinds: credentialsKinds)
    case .accessTypes(let accessTypes):
        AccessTypePicker(accessTypes: accessTypes, onSelection: onSelection)
    }
}
