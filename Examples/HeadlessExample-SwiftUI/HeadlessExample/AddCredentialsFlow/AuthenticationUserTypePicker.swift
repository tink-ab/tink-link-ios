import SwiftUI
import TinkLink

struct AuthenticationUserTypePicker: View {
    var authenticationUserTypes: [ProviderTree.AuthenticationUserTypeNode]

    var body: some View {
        List(authenticationUserTypes, id: \.id) { authenticationUserType in
            NavigationLink(destination: authenticationUserType.destinationView()) {
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
        @unknown default:
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
        @unknown default: return "unknown"
        }
    }
}

struct AuthenticationUserTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationUserTypePicker(authenticationUserTypes: [])
    }
}

extension ProviderTree.AuthenticationUserTypeNode {
    @ViewBuilder
    func destinationView() -> some View {
        switch self {
        case .provider(let provider):
            AddCredentialsView(provider: provider)
                .navigationTitle(provider.displayName)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        case .accessTypes(let accessTypes):
            AccessTypePicker(accessTypes: accessTypes)
        }
    }
}
