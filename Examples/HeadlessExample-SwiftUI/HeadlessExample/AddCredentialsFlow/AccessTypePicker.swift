import SwiftUI
import TinkLink

struct AccessTypePicker: View {
    var accessTypes: [ProviderTree.AccessTypeNode]

    var body: some View {
        List(accessTypes, id: \.id) { accessType in
            NavigationLink(destination: destinationView(for: accessType)) {
                switch accessType.accessType {
                case .openBanking:
                    Text("Open Banking")
                case .other:
                    Text("Other")
                case .unknown:
                    Text("Unknown")
                }
            }
        }
        .navigationTitle("Choose Access Type")
    }
}

struct AccessTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        AccessTypePicker()
    }
}

func destinationView(for accessType: ProviderTree.AccessTypeNode) -> some View {
    return Group {
        switch accessType {
        case .provider(let provider):
            Text(provider.displayName)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        }
    }
}
