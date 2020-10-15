import SwiftUI
import TinkLink

struct FinancialInsititutionPicker: View {
    var financialInstitutions: [ProviderTree.FinancialInstitutionNode]
    var onSelection: (Provider) -> Void

    var body: some View {
        List(financialInstitutions, id: \.financialInstitution) { financialInstitution in
            NavigationLink(destination: destinationView(for: financialInstitution, onSelection: onSelection)) {
                Text(financialInstitution.financialInstitution.name)
            }
        }
        .navigationTitle("Choose Financial Institution")
    }
}

struct FinancialInsititutionPicker_Previews: PreviewProvider {
    static var previews: some View {
        FinancialInsititutionPicker(financialInstitutions: [], onSelection: { _ in })
    }
}

func destinationView(for financialInstitution: ProviderTree.FinancialInstitutionNode, onSelection: @escaping (Provider) -> Void) -> some View {
    Group {
        switch financialInstitution {
        case .provider(let provider):
            Button(action: { onSelection(provider) }) {
                Text(provider.displayName)
            }
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        case .accessTypes(let accessTypes):
            AccessTypePicker(accessTypes: accessTypes, onSelection: onSelection)
        case .authenticationUserTypes(let authenticationUserTypes):
            AuthenticationUserTypePicker(authenticationUserTypes: authenticationUserTypes, onSelection: onSelection)
        }
    }
}
