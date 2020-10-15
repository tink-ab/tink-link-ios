import SwiftUI
import TinkLink

struct AccessTypePicker: View {
    var accessTypes: [ProviderTree.AccessTypeNode]
    var onSelection: (Provider) -> Void

    var body: some View {
        List(accessTypes, id: \.id) { accessType in
            NavigationLink(destination: destinationView(for: accessType, onSelection: onSelection)) {
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
        AccessTypePicker(accessTypes: [], onSelection: { _ in })
    }
}

@ViewBuilder
func destinationView(for accessType: ProviderTree.AccessTypeNode, onSelection: @escaping (Provider) -> Void) -> some View {
    switch accessType {
    case .provider(let provider):
        Button(action: { onSelection(provider) }) {
            Text(provider.displayName)
        }
    case .credentialsKinds(let credentialsKinds):
        CredentialsKindPicker(credentialsKinds: credentialsKinds)
    }
}
