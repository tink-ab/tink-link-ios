import SwiftUI
import TinkLink

struct FinancialServicesNodePicker: View {
    var financialServicesNodes: [ProviderTree.FinancialServicesNode]

    var body: some View {
        List(financialServicesNodes, id: \.id) { financialServicesNode in
            NavigationLink(destination: financialServicesNode.makeDestinationView()) {
                FinancialServicesNodeRow(financialServices: financialServicesNode.financialServices)
            }
        }
        .navigationTitle("Choose Authentication Type")
    }
}

struct FinancialServicesNodeRow: View {
    var financialServices: [Provider.FinancialService]

    var body: some View {
        switch financialServices.first?.segment {
        case .personal:
            Text("Personal")
        case .business:
            Text("Business")
        case .unknown, .none:
            Text("Unknown")
        @unknown default:
            Text("Unknown")
        }
    }
}

extension ProviderTree.FinancialServicesNode {
    @ViewBuilder
    func makeDestinationView() -> some View {
        switch self {
        case .provider(let provider):
            AddCredentialsView(provider: provider)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        case .accessTypes(let accessTypes):
            AccessTypePicker(accessTypes: accessTypes)
        }
    }
}
