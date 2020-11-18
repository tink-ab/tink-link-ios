import SwiftUI
import TinkLink

struct AccessTypePicker: View {
    var accessTypes: [ProviderTree.AccessTypeNode]

    var body: some View {
        List(accessTypes, id: \.id) { accessType in
            NavigationLink(destination: accessType.makeDestinationView()) {
                AccessTypeRow(accessType: accessType.accessType)
            }
        }
        .navigationTitle("Choose Access Type")
    }
}

struct AccessTypeRow: View {
    var accessType: Provider.AccessType

    var body: some View {
        switch accessType {
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
