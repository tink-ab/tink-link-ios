import SwiftUI
import TinkLink

struct AccessTypePicker: View {
    var accessTypes: [ProviderTree.AccessTypeNode]

    var body: some View {
        List(accessTypes, id: \.id) { accessType in
            NavigationLink(destination: accessType.makeDestinationView()) {
                switch accessType.accessType {
                case .openBanking:
                    Text("Open Banking")
                case .other:
                    Text("Other")
                case .unknown:
                    Text("Unknown")
                @unknown default:
                    Text("Unknown")
                }
            }
        }
        .navigationTitle("Choose Access Type")
    }
}

extension ProviderTree.AccessTypeNode {
    @ViewBuilder
    func makeDestinationView() -> some View {
        switch self {
        case .provider(let provider):
            AddCredentialsView(provider: provider)
                .navigationTitle(provider.displayName)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        }
    }
}
